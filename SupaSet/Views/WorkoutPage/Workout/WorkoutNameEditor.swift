//
//  WorkoutNameEditor.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/20/25.
//

import SwiftUI

struct WorkoutNameEditor: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) private var dismiss
    let workout: WorkoutRecord
    @State private var workoutName: String = ""
    @State private var debouncedName: String = ""
    var font: Font = .title
    var body: some View {
        TextField("New Workout", text: $workoutName)
            .multilineTextAlignment(.center)
            .font(font.bold())
            .textFieldStyle(.plain)
            .submitLabel(.done)
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                workoutName = workout.name
                debouncedName = workout.name
            }
            .onChange(of: debouncedName) { oldValue, newValue in
                if newValue != workout.name {
                    updateName(newValue)
                }
            }
            .debounced(value: $workoutName, debouncedValue: $debouncedName)
    }
    private func updateName(_ newName: String) {
        Task { @MainActor in
            do {
                var updatedWorkout = workout
                updatedWorkout.name = newName
                try await _ = appDatabase.updateWorkout(updatedWorkout)
            } catch {
                
            }
        }
    }
}
