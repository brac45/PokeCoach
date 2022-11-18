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
    
    var body: some View {
        VStack {
            Text(hrData.activityName)
            Chart {
                ForEach(hrData.data) {
                    LineMark(
                        x: .value("Time", $0.ts, unit: .second),
                        y: .value("Heartrate", $0.hr)
                    )
                }
            }
        }
    }
}

