//
//  SettingsView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/18/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var hrData: HeartrateModelData
    @State var debugText: String = "Multiline Debug Text\n"
    
    func loadDummyData() {
        debugText.append("Loading dummy data..\n")
        hrData.fillWithDummyData()
    }
    
    func loadGPXRunData1() {
        debugText.append("Loading data from \(SampleData.Run1.rawValue)")
        hrData.ClearAndfillWithGPXData(filename: SampleData.Run1)
    }
    
    func clearData() {
        debugText.append("Clearing data...\n")
        hrData.clearAllData()
    }
    
    var body: some View {
        //let testStr = HeartrateModelData.getStringPathForGPXData()
        
        VStack {
            Menu("Load Data") {
                Button("Dummy Data", action: loadDummyData)
                Button("Run Data 1", action: loadGPXRunData1)
                Button("Clear Data", role: .destructive, action: clearData)
            }
            TextEditor(text: $debugText)
        }
        .padding()
    }
}
