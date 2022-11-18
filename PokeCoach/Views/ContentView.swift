//
//  ContentView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var hrData = HeartrateModelData()

    var body: some View {
        TabView() {
            DataViewTab(hrData: hrData)
                .tabItem {
                    Label("Chart", systemImage: "chart.xyaxis.line")
                }
            
            SettingsTab()
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
    
    var body: some View {
        VStack {
            HeartrateView(hrData: hrData)
        }
    }
}

struct SettingsTab: View {
    var body: some View {
        VStack {
            SettingsView()
        }
    }
}
