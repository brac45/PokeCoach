//
//  ContentView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var hrData = HeartrateModelData()
    @StateObject var hapticManager = HapticsManager()

    var body: some View {
        TabView() {
            DataViewTab(hrData: hrData, hapticManager: hapticManager)
                .tabItem {
                    Label("Chart", systemImage: "chart.xyaxis.line")
                }
            
            SettingsTab(hrData: hrData, hapticManager: hapticManager)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DataViewTab: View {
    @ObservedObject var hrData: HeartrateModelData
    @ObservedObject var hapticManager: HapticsManager
    
    var body: some View {
        VStack {
            HeartrateView(hrData: hrData, hapticManager: hapticManager)
        }
    }
}

struct SettingsTab: View {
    @ObservedObject var hrData: HeartrateModelData
    @ObservedObject var hapticManager: HapticsManager
    
    var body: some View {
        VStack {
            SettingsView(hrData: hrData, hapticManager: hapticManager)
        }
    }
}
