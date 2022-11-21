//
//  HeartrateView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI
import Charts
import CoreHaptics

struct HeartrateView: View {
    @ObservedObject var hrData: HeartrateModelData
    
    @State private var chartIdx = 0.0
    
    @StateObject var hapticManager = HapticManager()
    
    var engine: CHHapticEngine!
    
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
            
            Slider(
                value: $chartIdx,
                in: hrData.xMin...hrData.xMax,
                step: 1,
                onEditingChanged: { editing in
                    print(editing)
                }
            )
            
            HStack {
                Spacer()
                Label("Time: \(dateToTimeString())", systemImage: "stopwatch")
                Spacer()
                Label("Heartrate: \(hrData.datapoints[Int(chartIdx)].hr)", systemImage: "heart")
                Spacer()
            }
            .symbolRenderingMode(.multicolor)
        }
        .padding()
        .onAppear {
            print("HeartrateView Appeared!")
            if hapticManager.supportsHaptics {
                print("Current device supports haptics")
                
            } else {
                print("No haptic engine")
            }
        }
        .onDisappear {
            print("HeartrateView Disappeared...")
        }
    }
}

