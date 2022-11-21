//
//  HapticManager.swift
//  PokeCoach
//
//  Created by Jong Ho Lee on 11/20/22.
//

import SwiftUI
import CoreHaptics

class HapticManager: ObservableObject {
    @Published var supportsHaptics: Bool
    
    init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
}
