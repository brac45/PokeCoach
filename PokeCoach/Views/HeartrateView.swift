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

struct HeartrateView: View {
    @ObservedObject var hrData: HeartrateModelData
    @ObservedObject var hapticManager: HapticsManager
    
    @State private var chartIdx: Double = 0.0
    
    @State private var minIdxForSpeech: Double = Double.infinity
    @State private var maxIdxForSpeech: Double = -1.0
    @State private var minHr: Int = 9999
    @State private var maxHr: Int = -1
    
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    func playSynthesizedSummary() {
        print("Current Min: \(minIdxForSpeech), max: \(maxIdxForSpeech)")
        if minIdxForSpeech < maxIdxForSpeech {
            if minHr >= 9999 || maxHr < 0 {
                return
            }
            
            // TODO: Build string here
            let summary = "From the range you explored, "
            
            let utterance = AVSpeechUtterance(string: summary)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.rate = 1
            
            print("Playing \(summary)")
            //let synthesizer = AVSpeechSynthesizer()
            speechSynthesizer.speak(utterance)
        }
    }
    
    func onIdxChange() {
        print("Idx change: \(chartIdx)")
        
        if hapticManager.doHapticFeedback {
            if chartIdx < minIdxForSpeech {
                print("SET min: \(minIdxForSpeech), max: \(maxIdxForSpeech)")
                minIdxForSpeech = chartIdx
            }
            if chartIdx > maxIdxForSpeech {
                print("SET min: \(minIdxForSpeech), max: \(maxIdxForSpeech)")
                maxIdxForSpeech = chartIdx
            }
            
            if hapticManager.doTransientInstead {
                /// TODO: Update frequency here
                hapticManager.updateTransientHapticInterval(bpm: hrData.datapoints[Int(chartIdx)].hr)
                hapticManager.playTransientPattern()
            } else {
                let curVal = Float(hrData.datapoints[Int(chartIdx)].hr)
                let refMax = Float(hrData.yMax)
                let refMin = Float(hrData.yMin)
                
                hapticManager.updateContinuousHapticParameters(refMax: refMax, refMin: refMin, curVal: curVal)
            }
        } else {
            minIdxForSpeech = Double.infinity
            maxIdxForSpeech = -1.0
            print("RESET min: \(minIdxForSpeech), max: \(maxIdxForSpeech)")
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
                Spacer(minLength: 20)
                Label("Time: \(dateToTimeString())", systemImage: "stopwatch")
                Spacer(minLength: 20)
                Label("Heartrate: \(hrData.datapoints[Int(chartIdx)].hr)", systemImage: "heart")
                Spacer()
                Button("Play Audio Summary", action: playSynthesizedSummary)
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
