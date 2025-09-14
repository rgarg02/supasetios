//
//  PreviousSetView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/25/25.
//

import SwiftUI
struct PreviousSetView: View {
    let text: String
    
    init(previousSet: ExerciseSetRecord?) {
        if let previousSet {
            text = "\(String(format: "%g", previousSet.weight)) x \(previousSet.reps)"
        } else {
            text = "--"
        }
    }
    
    var body: some View {
        Text(text)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }
}
