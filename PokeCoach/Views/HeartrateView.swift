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
    
    @State private var speed = 50.0
    @State private var isEditing = false
    
    
    
    var body: some View {
        VStack {
            Text(hrData.activityName)
            
            Chart(hrData.datapoints) {
                LineMark(
                    x: .value("Time", $0.ts, unit: .second),
                    y: .value("Heartrate", $0.hr)
                )
            }
            .padding()
            .chartYScale(domain: hrData.yMin...hrData.yMax)
            
            Slider(
                value: $speed,
                in: 0...100,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            
            Text("\(speed)")
        }
        .padding()
    }
}

