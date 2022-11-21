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
    
    @State private var chartIdx: Double = 0.0
    
    @StateObject var hapticManager = HapticManager()
    
    func onIdxChange() {
        print("Idx change: \(chartIdx)")
        
        let curVal = Float(hrData.datapoints[Int(chartIdx)].hr)
        let refMax = Float(hrData.yMax)
        let refMin = Float(hrData.yMin)
        
        hapticManager.updateContinuousHapticParameters(refMax: refMax, refMin: refMin, curVal: curVal)
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
            
            Slider(
                value: $chartIdx,
                in: hrData.xMin...hrData.xMax,
                step: 1,
                onEditingChanged: { editing in
                    hapticManager.doHapticFeedback = editing
                    hapticManager.playContinuousPattern()
                }
            )
            .onChange(of: chartIdx) { value in
                onIdxChange()
            }
            
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
    }
}
