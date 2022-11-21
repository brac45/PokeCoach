//
//  HeartrateView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI
import Charts

struct HeartrateView: View {
    @ObservedObject var hrData: HeartrateModelData
    
    @State private var chartIdx = 0.0
    @State private var isEditing = false
    
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
                step: 1
            )
            
            Text("Time: \(dateToTimeString())")
        }
        .padding()
    }
}

