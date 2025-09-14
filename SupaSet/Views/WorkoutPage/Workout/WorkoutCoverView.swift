//
//  WorkoutCoverView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/20/25.
//

import SwiftUI
import GRDB
import SwiftfulRouting
struct WorkoutCoverView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) private var dismiss
    let workout: WorkoutRecord
    let animation: Namespace.ID
    @State private var offset: CGFloat = .zero
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WorkoutEditView(workout: workout)
            }
            .frame(maxWidth: .infinity)
            .background(.background)
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button {
                        finishWorkout()
                        dismiss()
                    } label: {
                        Label("Finish", systemImage: "flag.pattern.checkered")
                    }
                }
            }
        }
    }
    private func finishWorkout() {
        Task { @MainActor in
            do {
                var updatedWorkout = workout
                updatedWorkout.endDate = Date()
                _ = try await appDatabase.updateWorkout(updatedWorkout)
            } catch {
                
            }
        }
    }
}

#Preview {
    @Previewable @State var animation = Namespace().wrappedValue
    let sampleWorkout = WorkoutRecord(
        id: 1,
        name: "Preview Workout",
        creationDate: Date(),
        modificationDate: Date(),
        endDate: nil,
        notes: "Preview notes"
    )
    return WorkoutCoverView(workout: sampleWorkout, animation: animation)
        .appDatabase(.withBodyweightExercises())
}
