//
//  HapticManager.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/20/22.
//

import SwiftUI
import CoreHaptics
import Combine

class HapticManager: ObservableObject {
    @Published var supportsHaptics: Bool
    @Published var doHapticFeedback: Bool
    
    var toggleSink: AnyCancellable?
    
    var engine: CHHapticEngine!
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
    
    private let initialIntensity: Float = 0.5
    private let initialSharpness: Float = 0.5
    
    init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        self.doHapticFeedback = false
        
        // TODO: Remove in production
        toggleSink = $doHapticFeedback.sink { v in
            print("doHapticFeedback: \(self.doHapticFeedback) -> \(v)")
        }
        
        if supportsHaptics {
            createAndStartHapticEngine()
            createContinuousHapticPlayer()
        }
    }
    
    func createAndStartHapticEngine() {
        do {
            print("Starting Haptic Engine...")
            self.engine = try CHHapticEngine()
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }
        
        self.engine.playsHapticsOnly = true
        
        self.engine.stoppedHandler = { reason in
            print("Stop Handler: engine stopped because \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt")
            case .applicationSuspended:
                print("Application suspended")
            case .idleTimeout:
                print("Idle timeout")
            case .systemError:
                print("System error")
            case .notifyWhenFinished:
                print("Playback finished")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            case .engineDestroyed:
                print("Engine destroyed.")
            @unknown default:
                print("Unknown error")
            }
        }
        
        // The reset handler provides an opportunity to restart the engine.
        self.engine.resetHandler = {
            
            print("Reset Handler: Restarting the engine.")
            
            do {
                // Try restarting the engine.
                try self.engine.start()
                
                // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
                //self.engineNeedsStart = false
                
                // Recreate the continuous player.
                self.createContinuousHapticPlayer()
                
            } catch {
                print("Failed to start the engine")
            }
        }
        
        // Start the haptic engine for the first time.
        do {
            try self.engine.start()
            print("Haptic engine started")
        } catch {
            print("Failed to start the engine: \(error)")
        }
    }
    
    func createContinuousHapticPlayer() {
        // Create an intensity parameter:
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                               value: initialIntensity)
        
        // Create a sharpness parameter:
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                               value: initialSharpness)
        
        // Create a continuous event with a long duration from the parameters.
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                            parameters: [intensity, sharpness],
                                            relativeTime: 0,
                                            duration: 100)
        
        do {
            // Create a pattern from the continuous haptic event.
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            
            // Create a player from the continuous haptic pattern.
            print("Making continuous player..")
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            print("Making continuous player.. Done!")
        } catch let error {
            print("Pattern Player Creation Error: \(error)")
        }
        
        continuousPlayer.completionHandler = { _ in
            print("Completion Handler Called")
        }
    }
    
    func updateContinuousHapticParameters(refMax: Float, refMin: Float, curVal: Float) {
        // Normalize intensity based on current data point
        let dynamicIntensity = (curVal - refMin)/(refMax - refMin)
        
        // Normalize sharpness based on current data point
        let dynamicSharpness = (curVal - refMin)/(refMax - refMin)
        
        // The perceived intensity value multiplies the original event parameter intensity by the dynamic parameter's value.
        //let perceivedIntensity = initialIntensity * dynamicIntensity
        
        // The perceived sharpness value adds the dynamic parameter to the original pattern's event parameter sharpness.
        //let perceivedSharpness = initialSharpness + dynamicSharpness
        
        if supportsHaptics {
            // Create dynamic parameters for the updated intensity & sharpness.
            let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                              value: dynamicIntensity,
                                                              relativeTime: 0)
            
            let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
                                                              value: dynamicSharpness,
                                                              relativeTime: 0)
            
            // Send dynamic parameters to the haptic player.
            do {
                print("Try continuousPlayer.sendParams [\(intensityParameter.value), \(sharpnessParameter.value)]")
                try continuousPlayer.sendParameters([intensityParameter, sharpnessParameter],
                                                    atTime: 0)
            } catch let error {
                print("Dynamic Parameter Error: \(error)")
            }
        }
    }
    
    func playContinuousPattern() {
        switch self.doHapticFeedback {
        case true:
            // Proceed if and only if the device supports haptics.
            if supportsHaptics {
                // Warm engine.
                do {
                    // Begin playing continuous pattern.
                    print("starting continuous pattern")
                    try continuousPlayer.start(atTime: CHHapticTimeImmediate)
                } catch let error {
                    print("Error starting the continuous haptic player: \(error)")
                }
            }
        case false:
            if supportsHaptics {
                // Stop playing the haptic pattern.
                do {
                    print("Stopping continuous pattern")
                    try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
                } catch let error {
                    print("Error stopping the continuous haptic player: \(error)")
                }
            }
        }
    }
}
