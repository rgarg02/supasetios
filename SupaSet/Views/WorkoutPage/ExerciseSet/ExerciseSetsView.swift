//
//  ExerciseSetsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/21/25.
//

import SwiftUI
import GRDBQuery
import GRDB

struct ExerciseSetsView: View {
    
    @Environment(\.appDatabase) private var appDatabase
    @Environment(ToolbarVC.self) private var toolbarVC
    @Query<ExerciseSetsRequest>
    private var sets: [CurrentAndPreviousSet]
    let padding: CGFloat
    let exerciseOrder: Int
    let workoutExerciseId: Int64
    init(workoutExerciseId: Int64, padding: CGFloat, exerciseOrder: Int) {
        _sets = Query(ExerciseSetsRequest(workoutExerciseId: workoutExerciseId))
        self.padding = padding
        self.exerciseOrder = exerciseOrder
        self.workoutExerciseId = workoutExerciseId
    }
    
    // Constants
    let spacing: CGFloat = 5
    var body: some View {
        VStack {
            ForEach(sets, id: \.current.id) { currentAndPreviousSet in
                let exerciseSet = currentAndPreviousSet.current
                let previousSet = currentAndPreviousSet.previous
                let workingSetOrder = currentAndPreviousSet.workingSetOrder
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            SetTypeIndicatorView(exerciseSetType: exerciseSet.setType, setOrder: workingSetOrder) { newType in
                                updateSetType(for: exerciseSet, to: newType)
                            }
                            
                            HStack(spacing: spacing){
                                PreviousSetView(previousSet: previousSet)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                // Column 3: Weight
                                WeightView(
                                    weight: previousSet?.weight ?? exerciseSet.weight,
                                    isDone: exerciseSet.isDone,
                                    fieldType: .weight(exerciseOrder, exerciseSet.order)
                                ){ _ in
                                    
                                }
                                
                                // Column 4: Reps
                                RepsView(
                                    reps: previousSet?.reps ?? exerciseSet.reps,
                                    isDone: exerciseSet.isDone,
                                    fieldType: .reps(exerciseOrder, exerciseSet.order)
                                ) { _ in
                                    
                                }
                                .frame(maxWidth: .infinity)
                                
                                // Column 5: Completion indicator
                                CompletionIndicatorView(isDone: exerciseSet.isDone) {
                                    toggleCompletion(for: exerciseSet)
                                }
                                .frame(width: 30)
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 40 - spacing - 2*padding - padding)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, padding/2)
                        .ignoresSafeArea()
                        .background(exerciseSet.isDone ? .green.opacity(0.7) : .clear)
                    }
                }
                .scrollDisabled(true)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .cornerRadius(12)
            }
            PlaceholderSetView(onTap: {
                addSet(for: workoutExerciseId)
            })
        }
        .animation(.easeInOut, value: sets)
    }
    // MARK: - Database Operations
    private func addSet(for workoutExerciseId: Int64) {
        Task {
            do {
                try await appDatabase.addSet(for: workoutExerciseId)
            }catch {
                // TODO:
            }
        }
    }
    /// Updates the set type for a given exercise set.
    private func updateSetType(for set: ExerciseSetRecord, to newType: SetType) {
        Task {
            var mutableSet = set
            mutableSet.setType = newType
            do {
                try await appDatabase.updateExerciseSet(mutableSet)
            } catch {
                // TODO: Add proper error handling
                print("Failed to update set type: \(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the weight for a given exercise set.
    private func updateWeight(for set: ExerciseSetRecord, to newWeight: Double) {
        Task {
            var mutableSet = set
            mutableSet.weight = newWeight
            do {
                try await appDatabase.updateExerciseSet(mutableSet)
            } catch {
                // TODO: Add proper error handling
                print("Failed to update weight: \(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the reps for a given exercise set.
    private func updateReps(for set: ExerciseSetRecord, to newReps: Int) {
        Task {
            var mutableSet = set
            mutableSet.reps = newReps
            do {
                try await appDatabase.updateExerciseSet(mutableSet)
            } catch {
                // TODO: Add proper error handling
                print("Failed to update reps: \(error.localizedDescription)")
            }
        }
    }
    
    /// Toggles the completion status for a given exercise set.
    private func toggleCompletion(for set: ExerciseSetRecord) {
        Task {
            var mutableSet = set
            mutableSet.isDone.toggle()
            do {
                try await appDatabase.updateExerciseSet(mutableSet)
            } catch {
                // TODO: Add proper error handling
                print("Failed to toggle completion: \(error.localizedDescription)")
            }
        }
    }
    
    
    @ViewBuilder
    func RowView(_ image: String, _ title: String) -> some View {
        HStack(spacing: 18) {
            Image(systemName: image)
                .font(.title3)
                .symbolVariant(.fill)
                .frame(width: 45, height: 45)
                .background(.background, in: .circle)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .fontWeight(.semibold)
                
                Text("This is a sample text description")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .contentShape(.rect)
    }
}

// The Preview remains unchanged
#Preview {
    let columns = [
        GridItem(.fixed(30)),      // Set type
        GridItem(.flexible()),     // Previous
        GridItem(.flexible()),     // Weight
        GridItem(.flexible()),     // Reps
        GridItem(.fixed(30))       // Completion
    ]
    return ExerciseSetsView(workoutExerciseId: 1, padding: 10, exerciseOrder: 1)
        .appDatabase(.workoutWithPopulatedExercise(workoutExerciseId: 1))
        .padding(10)
}
