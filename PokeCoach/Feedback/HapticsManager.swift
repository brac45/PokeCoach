//
//  HapticManager.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/20/22.
//

import SwiftUI
import CoreHaptics
import Combine

class HapticsManager: ObservableObject {
    @Published var supportsHaptics: Bool
    @Published var doHapticFeedback: Bool
    @Published var doTransientInstead: Bool
    
    var toggleSink: AnyCancellable?
    
    var engine: CHHapticEngine!
    private var continuousPlayer: CHHapticAdvancedPatternPlayer!
    
    /// Continuous member values
    private let initialIntensity: Float = 0.5
    private let initialSharpness: Float = 0.5
    
    /// Transient member values
    private let transientIntensity: Float = 1
    private let transientSharpness: Float = 1
    private let transientInitialDelay: Int = 100
    private var relativeBPM: Int
    private let MIN_BPM: Int = 20
    private let MAX_BPM: Int = 300
    
    private var transientTimer: DispatchSourceTimer?
    
    init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        self.doHapticFeedback = false
        self.doTransientInstead = false
        self.relativeBPM = MIN_BPM
        
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
            DispatchQueue.main.async {
                // Restore original color.
                self.doHapticFeedback = false
            }
        }
    }
    
    func updateTransientHapticInterval(refMax: Int, refMin: Int, curVal: Int) {
        // Convert to relative beats per minute, drop decimals
        let converted:Int = Int((((Float(curVal) - Float(refMin)) / (Float(refMax) - Float(refMin))) * (Float(MAX_BPM)-Float(MIN_BPM))) + Float(MIN_BPM))
        
        if converted < MIN_BPM {
            self.relativeBPM = MIN_BPM
        } else if converted > MAX_BPM {
            self.relativeBPM = MAX_BPM
        } else {
            self.relativeBPM = Int(converted)
        }
    }
    
    func updateContinuousHapticParameters(refMax: Float, refMin: Float, curVal: Float) {
        // Normalize intensity based on current data point
        let dynamicIntensity = (curVal - refMin)/(refMax - refMin)
        
        // Normalize sharpness based on current data point
        let dynamicSharpness = (curVal - refMin)/(refMax - refMin)
        
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
    
    private func playHapticTransient() {
        // Abort if the device doesn't support haptics.
        if !supportsHaptics {
            return
        }
        
        // Create an intensity parameter:
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity,
                                               value: transientIntensity)
        
        // Create a sharpness parameter:
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness,
                                               value: transientSharpness)
        
        // Create a continuous event with a long duration from the parameters.
        let transientEvent = CHHapticEvent(eventType: .hapticTransient,
                                            parameters: [intensity, sharpness],
                                            relativeTime: 0)
        
        do {
            print("Transient Intensity: \(intensity.value)")
            print("Transient Sharpness: \(sharpness.value)")
            // Create a pattern from the transient haptic event.
            let pattern = try CHHapticPattern(events: [transientEvent], parameters: [])
            
            // Create a player from the continuous haptic pattern.
            print("Making transient player..")
            let transientPlayer = try engine.makePlayer(with: pattern)
            try transientPlayer.start(atTime: CHHapticTimeImmediate) // Play now.
            print("Making transient player.. Done!")
        } catch let error {
            print("Pattern Player Creation Error: \(error)")
        }
    }
    
    func playTransientPattern() {
        switch self.doHapticFeedback {
        case true:
            // Create a timer to play subsequent transient patterns in succession.
            transientTimer?.cancel()
            transientTimer = DispatchSource.makeTimerSource(queue: .main)
            guard let timer = transientTimer else {
                print("Something happened")
                return
            }
            
            // TODO: Calculate repeat delay with bpm
            let repeatingDelay: Int = Int(60000/self.relativeBPM)
            print("Scheduling timer")
            print("RepeatingDelay(ms): \(repeatingDelay)")
            timer.schedule(deadline: .now() + .milliseconds(self.transientInitialDelay), repeating: .milliseconds(repeatingDelay))
            timer.setEventHandler() { [unowned self] in
                self.playHapticTransient()
            }
            
            // Activate the timer.
            timer.resume()
            
        case false:
            // Stop the transient timer.
            transientTimer?.cancel()
            transientTimer = nil
        }
    }
}
