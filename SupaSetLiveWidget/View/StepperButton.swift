//
//  StepperButton.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//


import SwiftUI
import AppIntents

struct StepperButton: View {
    let systemName: String
    let intent: any AppIntent

    var body: some View {
        Button(intent: intent) {
            Image(systemName: systemName)
                .foregroundStyle(Color.theme.bg)
                .padding(7)
        }
        .frame(maxHeight: .infinity)
        .buttonStyle(PlainButtonStyle())
        .background(Color.theme.primary)
        .clipShape(.circle)
    }
}
#Preview {
    StepperButton(systemName: "plus", intent: CompleteSetIntent())
}
