//
//  ContentView.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/7/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HeartrateView()
            ChartNavigatorView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
