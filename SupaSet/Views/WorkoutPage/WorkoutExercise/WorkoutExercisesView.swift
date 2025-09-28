//
//  WorkoutExercisesView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/18/25.
//

import SwiftUI
import GRDBQuery
import GRDB


struct WorkoutExercisesView: View {
    
    @Environment(\.appDatabase) private var appDatabase
    @Query<WorkoutExercisesRequest>
    private var exercises: [WorkoutExerciseWithExercise]
    let isNew: Bool
    init(workoutID: Int64, isNew: Bool) {
        self.isNew = isNew
        _exercises = Query(WorkoutExercisesRequest(workoutId: workoutID))
    }
    let padding: CGFloat = 10
    @State private var selectedMuscle: MuscleGroup?
    var body: some View {
        ForEach(exercises, id: \.workoutExercise.id) { exercise in
            let workoutExercise = exercise.workoutExercise
            let exercise = exercise.exercise
            VStack {
                HStack {
                    ExerciseNameView(exerciseId: workoutExercise.exerciseID)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ExerciseOptions {
                        deleteExercise(workoutExercise)
                    } replaceExercise: { exerciseID in
                        if let exerciseID {
                            replaceExercise(workoutExercise, for: exerciseID)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                ExerciseSetsColumnNames()
                ExerciseSetsView(workoutExerciseId: workoutExercise.id!, padding: padding, exerciseOrder: workoutExercise.order)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
            }
            .padding(padding)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        }
        .animation(.easeInOut, value: exercises)
    }
    private func deleteExercise(_ exercise: WorkoutExerciseRecord) {
        Task{
            do {
                try await appDatabase.deleteWorkoutExercise(exercise)
            } catch {
                // TODO: 
            }
        }
    }
    private func replaceExercise(_ exercise: WorkoutExerciseRecord, for exerciseID: String) {
        Task{
            do {
                var exercise = exercise
                exercise.exerciseID = exerciseID
                _ = try await appDatabase.updateWorkoutExercise(exercise)
            } catch {
                // TODO: 
            }
        }
    }
    @ViewBuilder
    func ExerciseSetsColumnNames() -> some View {
        HStack(spacing: 5){
            Text("Set")
                .frame(width: 40)
            Text("Previous")
                .frame(maxWidth: .infinity)
            Text("Weight")
                .frame(maxWidth: .infinity)
            Text("Reps")
                .frame(maxWidth: .infinity)
            Image(systemName: "checkmark")
                .frame(width: 40)
        }
    }
}
