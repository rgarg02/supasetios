//
//  ExerciseSetsViewNew.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI

struct TemplateExerciseSetsView: View {
    let templateVM: TemplateVM
    @Binding var fullExercise: FullTemplateExercise
    let padding: CGFloat
    let spacing: CGFloat = 5
    var body: some View {
        VStack {
            ForEach($fullExercise.templateExerciseSets, id: \.order) { $exerciseSet in
                let workingSetOrder = fullExercise.templateExerciseSets
                    .filter({$0.type == "working"})
                    .filter({$0.order < exerciseSet.order})
                    .count
                let exerciseOrder = fullExercise.templateExercise.order
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: spacing) {
                            SetTypeIndicatorView(exerciseSetType: exerciseSet.setType, setOrder: workingSetOrder) { newType in
                                templateVM.updateSetType(for: &exerciseSet, to: newType)
                            }
                            HStack(spacing: spacing){
                                WeightView(
                                    weight: exerciseSet.weight,
                                    fieldType: .weight(fullExercise.templateExercise.order, exerciseSet.order)
                                ){ newWeight in
                                    templateVM.updateSetWeight(for: &exerciseSet, to: newWeight)
                                }
                                .frame(maxWidth: .infinity)
                                HStack {
                                    Group {
                                        // Use the repType from the protocol.
                                        switch exerciseSet.repType {
                                        case .reps(let reps):
                                            TemplateRepsView(reps: reps, repType: exerciseSet.repType, fieldType: .reps(exerciseOrder, exerciseSet.order)) { newReps in
                                                exerciseSet.repType = .reps(newReps)
                                            }
                                        case .range(let lowerBound, let upperBound):
                                            TemplateRepsView(reps: lowerBound, repType: exerciseSet.repType, fieldType: .reps(exerciseOrder, exerciseSet.order)) { newLowerBound in
                                                let upperUnwrapped = upperBound ?? newLowerBound
                                                exerciseSet.repType = .range(newLowerBound, upperUnwrapped)
                                            }
                                            Text("-")
                                            TemplateRepsView(reps: upperBound, repType: exerciseSet.repType, fieldType: .reps(exerciseOrder, exerciseSet.order, 1)) { newUpperBound in
                                                let lowerUnwrapped = lowerBound ?? newUpperBound
                                                exerciseSet.repType = .range(lowerUnwrapped, newUpperBound)
                                            }
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                Button {
                                    switch exerciseSet.repType {
                                    case .reps(let reps):
                                        exerciseSet.repType = .range(reps, reps)
                                    case .range(let lower, _):
                                        exerciseSet.repType = .reps(lower)
                                    }
                                } label: {
                                    Image(systemName: exerciseSet.repType.description == "Reps" ? "textformat.123" : "arrow.left.and.right")
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.theme.text)
                                        .contentTransition(.symbolEffect(.replace, options: .speed(2)))
                                        .background(.regularMaterial, in: .circle)
                                    
                                }
                            }
                            .frame(width: UIScreen.main.bounds.size.width - 40 - spacing - 2*padding - padding)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, padding/2)
                        .ignoresSafeArea()
                        .background(.clear)
                    }
                }
                .scrollDisabled(true)
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .cornerRadius(12)
            }
            PlaceholderSetView(onTap: {
                templateVM.addSet(for: fullExercise)
            })
        }
    }
}
