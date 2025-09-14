//
//  ExerciseSelctionRow.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import SwiftUI

struct ExerciseSelctionRow: View {
    let exercise: ExerciseJSON
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Name and optional frequency
                HStack(alignment: .firstTextBaseline) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    if let frequency = exercise.frequency, frequency != 0 {
                        Text("(\(frequency))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Primary Muscles
                if !exercise.primaryMuscles.isEmpty {
                    Text("Primary: \(exercise.primaryMuscles.map { $0.rawValue.capitalized }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1) // Keep it concise
                }
                
                // Details: Equipment, Mechanic, Force, Level as capsules
                HStack(spacing: 6) {
                    if let equipment = exercise.equipment {
                        CapsuleText(text: equipment.rawValue.capitalized)
                    }
                    if let mechanic = exercise.mechanic {
                        CapsuleText(text: mechanic.rawValue.capitalized)
                    }
                    if let force = exercise.force {
                        CapsuleText(text: force.rawValue.capitalized)
                    }
                    CapsuleText(text: exercise.level.rawValue.capitalized)
                }
                .font(.caption2)
            }
            
            Spacer()
            
            // Optional: Add an accessory indicator if needed, e.g., Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// Helper view for capsule-like tags
private struct CapsuleText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.15))
            .cornerRadius(8)
            .lineLimit(1) // Ensures the text stays on one line within the capsule
    }
}

#Preview {
    ExerciseSelctionRow(exercise: ExerciseJSON.sample)
        .padding(.horizontal) // For preview context
}
