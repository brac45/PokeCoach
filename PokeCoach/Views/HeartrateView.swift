//
//  HeartrateView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI
import Charts
import CoreHaptics
import AVFoundation

enum PlayAudioState {
    case initial, setting, ready
}

struct HeartrateView: View {
    @ObservedObject var hrData: HeartrateModelData
    @ObservedObject var hapticManager: HapticsManager
    
    @State private var chartIdx: Double = 0.0
    
    @State private var minIdxForSpeech: Double = Double.infinity
    @State private var maxIdxForSpeech: Double = -1.0
    @State private var minHr: Int = 9999
    @State private var maxHr: Int = -1
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    @State private var audioState: PlayAudioState = PlayAudioState.initial
    
    func playSynthesizedSummary() {
        if audioState != PlayAudioState.ready {
            print("Audio is not ready")
            audioState = PlayAudioState.initial
            return
        }
        
        print("Current Min: \(minIdxForSpeech), max: \(maxIdxForSpeech)")
        
        if minIdxForSpeech < maxIdxForSpeech {
            if minHr >= 9999 || maxHr < 0 {
                return
            }
            
            var sum = 0
            var count = 0
            for i in Int(minIdxForSpeech)...Int(maxIdxForSpeech) {
                sum += hrData.datapoints[Int(i)].hr
                count += 1
            }
            let rangedMeanHr = Double(sum) / Double(count)
            let relativeChange = Int(((rangedMeanHr - hrData.meanHr) / hrData.meanHr) * 100)
            
            let summary = "From the range you indicated, your minimum heart rate is \(minHr) beats per minute, and your maximum heart rate is \(maxHr) beats per minute. Your averate heart rate in this range is \(Int(rangedMeanHr)) beats per minute, which is a \(relativeChange) percent change from the overall average of your run. Your overall average was \(Int(hrData.meanHr))."
            
            let utterance = AVSpeechUtterance(string: summary)
            utterance.volume =  1.0
            
            let voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.voice = voice
            
            print("Playing \(summary)")
            self.speechSynthesizer.speak(utterance)
        }
        
        audioState = PlayAudioState.initial
    }
    
    func setFirstPointForAudio() {
        minIdxForSpeech = chartIdx
        audioState = PlayAudioState.setting
    }
    
    func setSecondPointForAudio() {
        // Check if they should be swapped
        if chartIdx < minIdxForSpeech {
            maxIdxForSpeech = minIdxForSpeech
            minIdxForSpeech = chartIdx
        } else if chartIdx > minIdxForSpeech {
            maxIdxForSpeech = chartIdx
        } else {
            // Should send a toast message or something
            audioState = PlayAudioState.initial
            return
        }
        
        // Find the y min and y max
        minHr = 9999
        maxHr = -1
        for i in Int(minIdxForSpeech)...Int(maxIdxForSpeech) {
            let val = hrData.datapoints[i].hr
            
            if val < minHr {
                minHr = val
            }
            if val > maxHr {
                maxHr = val
            }
        }
        
        audioState = PlayAudioState.ready
    }
    
    func onIdxChange() {
        print("Idx change: \(chartIdx)")
        
        if hapticManager.doHapticFeedback {
            if hapticManager.doTransientInstead {
                hapticManager.updateTransientHapticInterval(refMax: hrData.yMax, refMin: hrData.yMin, curVal: hrData.datapoints[Int(chartIdx)].hr)
                hapticManager.playTransientPattern()
            } else {
                let curVal = Float(hrData.datapoints[Int(chartIdx)].hr)
                let refMax = Float(hrData.yMax)
                let refMin = Float(hrData.yMin)
                
                hapticManager.updateContinuousHapticParameters(refMax: refMax, refMin: refMin, curVal: curVal)
            }
        }
    }
    
    func dateToTimeString() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        return timeFormatter.string(from: hrData.datapoints[Int(chartIdx)].ts)
    }
    
    var body: some View {
        VStack {
            Text(hrData.activityName)
            
            Chart(hrData.datapoints) {
                LineMark(
                    x: .value("Time", $0.ts, unit: .second),
                    y: .value("Heartrate", $0.hr)
                )
                RuleMark(x: .value("Current", hrData.datapoints[Int(chartIdx)].ts))
                    .foregroundStyle(.red)
            }
            .padding()
            .chartYScale(domain: hrData.yMin...hrData.yMax)
            
            HStack {
                Slider(
                    value: $chartIdx,
                    in: hrData.xMin...hrData.xMax,
                    step: 1,
                    onEditingChanged: { editing in
                        print("Change in slider")
                    }
                )
                    .onChange(of: chartIdx) { value in
                        onIdxChange()
                    }
                
            }
            
            HStack {
                Spacer()
                Label("Time: \(dateToTimeString())", systemImage: "stopwatch")
                Spacer()
                Label("Heartrate: \(hrData.datapoints[Int(chartIdx)].hr)", systemImage: "heart")
                Spacer()
                if self.audioState == PlayAudioState.initial {
                    Button("Set First Point", action: setFirstPointForAudio)
                } else if self.audioState == PlayAudioState.setting {
                    Button("Set Last Point", action: setSecondPointForAudio)
                } else if self.audioState == PlayAudioState.ready {
                    Button("Play Audio Summary", action: playSynthesizedSummary)
                }
                Spacer()
                Toggle(isOn: $hapticManager.doHapticFeedback) {
                    Text("Haptics")
                        .frame(maxWidth: 70, alignment: .trailing)
                }
                    .onChange(of: hapticManager.doHapticFeedback) { value in
                        if !hapticManager.doTransientInstead {
                            hapticManager.playContinuousPattern()
                        } else {
                            hapticManager.playTransientPattern()
                        }
                    }
                    .frame(maxWidth: 150)
            }
            .symbolRenderingMode(.multicolor)
        }
        .padding()
    }
}
