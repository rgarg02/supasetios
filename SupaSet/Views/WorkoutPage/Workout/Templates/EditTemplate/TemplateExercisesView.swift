//
//  WorkoutExercisesView.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/4/25.
//


import SwiftUI

struct TemplateExercisesView: View {
    @Bindable var templateVM: TemplateVM
    let padding: CGFloat = 10
    var body: some View {
        ForEach($templateVM.fullExercises, id: \.templateExercise) { $fullExercise in
            VStack {
                HStack {
                    ExerciseNameView(exerciseID: fullExercise.templateExercise.exerciseID)
                    ExerciseOptions {
                        templateVM.deleteExercise(fullExercise.templateExercise)
                    } replaceExercise: { exerciseID in
                        if let exerciseID {
                            templateVM.replaceExercise(fullExercise.templateExercise, for: exerciseID)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                ExerciseSetsColumnNames()
                TemplateExerciseSetsView(templateVM: templateVM, fullExercise: $fullExercise, padding: padding)

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
            Text("Weight")
                .frame(maxWidth: .infinity)
            Text("Reps/Range")
                .frame(maxWidth: .infinity)
            Text("")
                .frame(width: 40)
        }
    }
}
