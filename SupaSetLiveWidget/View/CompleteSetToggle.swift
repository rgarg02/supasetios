//
//  CompleteSetToggle.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//


// Shared/CompleteSetToggle.swift

import SwiftUI
import AppIntents

struct CompleteSetToggle: View {
    let isCompleted: Bool
    let intent: any AppIntent

    var body: some View {
        Toggle(isOn: isCompleted, intent: intent) {
            // No label needed here
        }
        .toggleStyle(ToggleButtonStyle())
    }
}