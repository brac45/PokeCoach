//
//  SettingsView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/18/22.
//

import SwiftUI

struct SettingsView: View {
    //@ObservedObject var hrData: HeartrateModelData
    
    var body: some View {
        let testStr = HeartrateModelData.getStringPathForGPXData()
        Text(testStr)
    }
}
