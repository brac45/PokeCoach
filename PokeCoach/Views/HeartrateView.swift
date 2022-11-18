//
//  HeartrateView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI
import Charts

struct HeartrateView: View {
    @StateObject private var hrData = 
    var body: some View {
        VStack {
            HeartrateViewChart()
        }
    }
}

struct HeartrateViewChart: View {
    var body: some View {
        Text("Heartrate chart should be here")
    }
}

struct HeartrateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartrateView()
    }
}
