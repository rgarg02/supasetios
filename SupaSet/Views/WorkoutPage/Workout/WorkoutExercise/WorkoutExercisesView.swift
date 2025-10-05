//
//  WorkoutExercisesViewNew.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI

struct WorkoutExercisesView: View {
    @Bindable var workoutVM: WorkoutVM
    let padding: CGFloat = 10
    var body: some View {
        ForEach($workoutVM.fullExercises, id: \.workoutExercise) { $fullExercise in
            VStack {
                HStack {
                    ExerciseNameView(exerciseID: fullExercise.workoutExercise.exerciseID)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ExerciseOptions {
                        workoutVM.deleteExercise(fullExercise.workoutExercise)
                    } replaceExercise: { exerciseID in
                        if let exerciseID {
                            workoutVM.replaceExercise(fullExercise.workoutExercise, for: exerciseID)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                ExerciseSetsColumnNames()
                ExerciseSetsView(workoutVM: workoutVM, fullExercise: $fullExercise, padding: padding)

            }
            .padding(padding)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
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
