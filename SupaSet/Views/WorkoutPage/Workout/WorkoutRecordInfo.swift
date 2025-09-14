//
//  WorkoutRecordInfo.swift
//  SupaSet
//
//  Created by Rishi Garg on 7/10/25.
//

import SwiftUI

struct WorkoutRecordInfo: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(ToolbarVC.self) private var toolbarVC
    let workout: WorkoutRecord
    @State private var workoutNotes: String = ""
    @State private var debouncedNotes: String = ""
    @FocusState private var isFocused: FieldType?
    let fieldType = FieldType.workoutNotes
    var font: Font = .body
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                    Text(workout.creationDate?.formatted() ?? Date().formatted())
                        .frame(alignment: .leading)
                }
                WorkoutTimer(date: workout.creationDate ?? .now)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text("Modified at:")
                Text(workout.modificationDate?.formatted() ?? Date().formatted())
                    .frame(alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $workoutNotes)
                    .multilineTextAlignment(.leading)
                    .font(font)
                    .padding()
                    .textFieldStyle(.plain)
                    .focused($isFocused, equals: fieldType)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.regularMaterial)
                            .stroke(toolbarVC.fieldType == fieldType ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
                    }
                    .textEditorStyle(.plain)
                if workoutNotes.isEmpty {
                    Text("Add your notes here")
                        .font(font)
                        .padding(EdgeInsets(top: 7, leading: 4, bottom: 0, trailing: 0))
                        .foregroundStyle(.placeholder)
                        .padding()
                }
            }
        }
        .padding()
        .onAppear {
            workoutNotes = workout.notes
            debouncedNotes = workout.notes
        }
        .debounced(value: $workoutNotes, debouncedValue: $debouncedNotes)
        .onChange(of: debouncedNotes) { oldValue, newValue in
            if newValue != workout.notes {
                updateNotes(newValue)
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if let newValue {
                toolbarVC.fieldType = newValue
            }
        }
        .onChange(of: toolbarVC.fieldType) { _, newValue in
            if let newValue, newValue == fieldType {
                isFocused = fieldType
            }
        }
        .onAppear {
            toolbarVC.allFields.insert(fieldType)
        }
    }
    private func updateNotes(_ newNotes: String) {
        Task { @MainActor in
            do {
                var updatedWorkout = workout
                updatedWorkout.notes = newNotes
                _ = try await appDatabase.updateWorkout(updatedWorkout)
            } catch {
                
            }
        }
    }
}

#Preview {
    let workout = WorkoutRecord(id: 1, name: "New Workout", notes: "")
    WorkoutRecordInfo(workout: workout)
        .appDatabase(.workoutWithPopulatedExercise(workoutId: 1))
}
