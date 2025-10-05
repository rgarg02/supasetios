//
//  PreviousSetView.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//


import SwiftUI
struct PreviousSetView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State private var text: String?
    let currentSet: ExerciseSetRecord
    let exerciseID: String
    var body: some View {
        Text(text ?? "-")
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(.primary.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .task {
                await fetchPreviousSet()
            }
    }
    
    func fetchPreviousSet() async {
        do {
            if let previousSet = try await appDatabase.fetchPreviousSet(for: currentSet, in: exerciseID) {
                text = "\(String(format: "%g", previousSet.weight)) x \(previousSet.reps)"
            } else {
                text = "--"
            }
        }catch {
            
        }
    }
}
