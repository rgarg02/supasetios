//
//  ExerciseSetsViewNew.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI

struct ExerciseSetsView: View {
    let workoutVM: WorkoutVM
    @Binding var fullExercise: FullExercise
    let padding: CGFloat
    let spacing: CGFloat = 5
    var body: some View {
        VStack {
            ForEach($fullExercise.exerciseSets, id: \.order) { $exerciseSet in
                let workingSetOrder = fullExercise.exerciseSets
                    .filter({$0.type == "working"})
                    .filter({$0.order < exerciseSet.order})
                    .count
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            SetTypeIndicatorView(exerciseSetType: exerciseSet.setType, setOrder: workingSetOrder) { newType in
                                workoutVM.updateSetType(for: &exerciseSet, to: newType)
                            }
                            
                            HStack(spacing: spacing){
                                PreviousSetView(currentSet: exerciseSet, exerciseID: fullExercise.workoutExercise.exerciseID)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                WeightView(
                                    weight: exerciseSet.weight,
                                    isDone: exerciseSet.isDone,
                                    fieldType: .weight(fullExercise.workoutExercise.order, exerciseSet.order)
                                ){ newWeight in
                                    workoutVM.updateSetWeight(for: &exerciseSet, to: newWeight)
                                }
                                
                                // Column 4: Reps
                                RepsView(
                                    reps: exerciseSet.reps,
                                    isDone: exerciseSet.isDone,
                                    fieldType: .reps(fullExercise.workoutExercise.order, exerciseSet.order)
                                ) { newReps in
                                    workoutVM.updateSetReps(for: &exerciseSet, to: newReps)
                                }
                                .frame(maxWidth: .infinity)
                                
                                CompletionIndicatorView(isDone: exerciseSet.isDone) {
                                    workoutVM.toggleSetCompletion(for: &exerciseSet)
                                }
                                .frame(width: 30)
                                
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 40 - spacing - 2*padding - padding)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, padding/2)
                        .ignoresSafeArea()
                        .background(exerciseSet.isDone ? Color.theme.success.opacity(0.7) : .clear)
                        .animation(.snappy, value: exerciseSet.isDone)
                    }
                }
                .scrollDisabled(true)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .cornerRadius(12)
            }
            PlaceholderSetView(onTap: {
                workoutVM.addSet(for: fullExercise)
            })
        }
    }
}
