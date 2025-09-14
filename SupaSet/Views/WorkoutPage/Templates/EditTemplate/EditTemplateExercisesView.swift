//
//  WorkoutExercisesView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/18/25.
//

import SwiftUI
import GRDBQuery
import GRDB


struct EditTemplateExercisesView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Binding var templateExercisesWithSet: [TemplateExerciseWithSets]
    @State private var exercisesName : [String: String] = [:]
    let padding: CGFloat = 10
    var body: some View {
        ForEach(templateExercisesWithSet, id: \.templateExercise) { templateExerciseWithSet in
            let templateExercise = templateExerciseWithSet.templateExercise
            let templateSets = templateExerciseWithSet.templateSets
            VStack {
                HStack {
                    ExerciseNameView(name: exercisesName[templateExercise.exerciseID] ?? "No Exercise Found")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ExerciseOptions {
                        deleteExercise(templateExercise)
                    } replaceExercise: { exerciseID in
                        if let exerciseID {
                            if let index = templateExercisesWithSet.firstIndex(where: {$0.templateExercise == templateExercise}) {
                                templateExercisesWithSet[index].templateExercise.exerciseID = exerciseID
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                ExerciseSetsColumnNames()
                EditTemplateSetsView(templateSets: Binding(get: {
                    templateSets
                }, set: { newSets in
                    if let index = templateExercisesWithSet.firstIndex(where: {$0.templateExercise == templateExercise}) {
                        templateExercisesWithSet[index].templateSets = newSets
                    }
                }), padding: padding, exerciseOrder: templateExercise.order)
                PlaceholderSetView(onTap: {
                    if let index = templateExercisesWithSet.firstIndex(where: {$0.templateExercise == templateExercise}) {
                        var newSet: TemplateExerciseSet = .init(type: .working, order: templateSets.count)
                        if let lastSet = templateSets.last {
                            newSet = TemplateExerciseSet(repType: lastSet.repType, weight: lastSet.weight, type: lastSet.setType, rpe: lastSet.rpe, notes: lastSet.notes, order: templateSets.count)
                        }
                        withAnimation(.easeInOut) {
                            templateExercisesWithSet[index].templateSets.append(newSet)
                        }
                    }
                })
                
            }
            .padding(padding)
        }
        
        .onAppear {
            updateNames()
        }
        .onChange(of: templateExercisesWithSet) { oldValue, newValue in
            updateNames()
        }
    }
    private func updateNames() {
        Task {
            var names: [String: String] = [:]
            for exercise in templateExercisesWithSet {
                if let name = try await appDatabase.fetchExerciseName(for: exercise.templateExercise.exerciseID) {
                    names[exercise.templateExercise.exerciseID] = name
                }
            }
            exercisesName = names
        }
    }
    private func deleteExercise(_ exercise: TemplateExercise) {
        templateExercisesWithSet.removeAll(where: {$0.templateExercise == exercise})
    }
    private func addSet(for exercise: TemplateExercise) {
    }
    @ViewBuilder
    func ExerciseSetsColumnNames() -> some View {
        HStack(spacing: 5){
            Text("Set")
                .frame(width: 40)
            Text("Weight")
                .frame(width: 100)
            Text("Reps")
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
