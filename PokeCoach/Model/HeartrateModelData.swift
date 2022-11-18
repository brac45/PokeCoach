//
//  HeartrateModel.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/11/22.
//

import SwiftUI

class HeartrateModelData: ObservableObject {
    @Published var data: [HeartrateDataPoint]
    @Published var activityName: String
    
    init() {
        self.data = []
        self.activityName = "Morning Run"
        
        self.fillWithDummyData()
    }

    func wipeAllData() {
        self.data.removeAll()
    }
    
    func fillWithDummyData() {
        self.data = [
            .init(hr: 100, isoDateString: "2022-11-17T11:27:48.000Z"),
            .init(hr: 139, isoDateString: "2022-11-17T11:28:56.000Z"),
            .init(hr: 152, isoDateString: "2022-11-17T11:29:37.000Z"),
            .init(hr: 142, isoDateString: "2022-11-17T11:30:27.000Z"),
            .init(hr: 121, isoDateString: "2022-11-17T11:41:35.000Z")
        ]
    }
}

struct HeartrateDataPoint: Identifiable {
    let id: UUID
    let hr: Int
    let ts: Date
    
    init(hr: Int, isoDateString: String) {
        self.id = UUID()
        self.hr = hr
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions.insert(.withFractionalSeconds)
        
        if let buf = isoFormatter.date(from: isoDateString) {
            self.ts = buf
        } else {
            self.ts = Date()
        }
    }
}
