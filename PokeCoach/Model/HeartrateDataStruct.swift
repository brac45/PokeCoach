//
//  HeartrateModel.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/11/22.
//

import SwiftUI

struct HeartrateDataStruct {
    /// Data series for the heartrate data
    struct Series: Identifiable {
        /// The name of the city.
        let activityName: String
        /// Epoch timestamp when the activity was logged, in seconds
        let loggedTime: Int

        /// Sampled heartrate by each epoch timestamp
        let HRByTime: [(heartrate: Int, s_timestamp: Int)]

        /// The identifier for the series.
        var id: String { return "\(activityName)_\(loggedTime)" }
    }

    /// Heartrate data for 2 example activities
    static let exampleData: [Series] = [
        .init(activityName: "example1", loggedTime: 1665485152, HRByTime: [
            (heartrate: 85, s_timestamp: 1665485156),
            (heartrate: 85, s_timestamp: 1665485156)
        ]),
        .init(activityName: "example1", loggedTime: 1665485152, HRByTime: [
            (heartrate: 85, s_timestamp: 1665485156),
            (heartrate: 85, s_timestamp: 1665485156)
        ])
    ]
}
