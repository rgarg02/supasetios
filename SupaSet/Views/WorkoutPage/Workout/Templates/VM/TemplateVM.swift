//
//  TemplateVM.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/4/25.
//


//
//  TemplateVM.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI
import GRDB

@MainActor
@Observable
final class TemplateVM {
    var template: WorkoutTemplate
    var fullExercises: [FullTemplateExercise] = []
    let appDatabase: AppDatabase
    let isNew: Bool
    
    @ObservationIgnored private var cancellable: AnyDatabaseCancellable?
    @ObservationIgnored private var deletedExercises: [TemplateExercise] = []
    @ObservationIgnored private var deletedSets: [TemplateExerciseSet] = []
    init(template: WorkoutTemplate? = nil,appDatabase: AppDatabase) {
        if let template {
            self.template = template
        } else {
            self.template = WorkoutTemplate(name: "New Template", notes: "")
        }
        self.appDatabase = appDatabase
        self.isNew = template == nil
        if !isNew {
            fetchFullExercises()
        }
    }
    private func fetchFullExercises(){
        Task {
            do {
                let fetchedExercises = try await appDatabase.fetchFullExercises(for: template)
                DispatchQueue.main.async {
                    self.fullExercises = fetchedExercises
                }
            } catch {
                
            }
        }
    }
    func updateTemplateName(to newName: String) {
        template.name = newName
    }
    func fetchActivePrimaryMuscles() async throws -> Set<MuscleGroup> {
        let exerciseIds = fullExercises.map({$0.templateExercise.exerciseID})
        return try await appDatabase.fetchActivePrimaryMuscles(for: exerciseIds)
    }
    func fetchActiveSecondaryMuscles() async throws -> Set<MuscleGroup> {
        let exerciseIds = fullExercises.map({$0.templateExercise.exerciseID})
        return try await appDatabase.fetchActiveSecondaryMuscles(for: exerciseIds)
    }
    func updateTemplateNotes(to newNotes: String) {
        template.notes = newNotes
    }
    // Add this method to your TemplateVM
    func saveChanges() async throws {
        do {
            try await appDatabase.saveChanges(to: template, exercisesToDelete: deletedExercises, setsToDelete: deletedSets, fullExercises: fullExercises)
        }catch {
            
        }
    }
    func deleteTemplate() {
        Task {
            do {
                try await appDatabase.deleteTemplate(template)
            }
        }
    }
    func finishTemplate() {
        Task {
            do {
                try await saveChanges()
            }catch {
                
            }
        }
    }
    func deleteExercise(_ exercise: TemplateExercise) {
        withAnimation(.snappy) {
            fullExercises.removeAll(where: {$0.templateExercise == exercise})
        }
        deletedExercises.append(exercise)
    }
    func replaceExercise(_ exercise: TemplateExercise, for exerciseID: String) {
        if let idx = fullExercises.firstIndex(where: { $0.templateExercise == exercise }) {
            Task { @MainActor in
                let previousSets = try await appDatabase.fetchPreviousCalendarSets(for: exerciseID)
                let copySets: [TemplateExerciseSet] = previousSets.map{TemplateExerciseSet($0, templateExerciseId: exercise.id)}
                deletedSets.append(contentsOf: fullExercises[idx].templateExerciseSets)
                withAnimation(.snappy) {
                    fullExercises[idx].templateExercise.exerciseID = exerciseID
                    fullExercises[idx].templateExerciseSets = copySets
                }
            }
        }
    }
    func addExercisesToTemplate(exerciseIds: [String]) {
        Task {
            for exerciseId in exerciseIds {
                do {
                    let previousSets = try await appDatabase.fetchPreviousCalendarSets(for: exerciseId).map({TemplateExerciseSet($0)})
                    let workoutExercise = TemplateExercise(exerciseID: exerciseId, order: fullExercises.count, notes: nil)
                    Task {@MainActor in
                        fullExercises.append(.init(templateExercise: workoutExercise, templateExerciseSets: previousSets))
                    }
                } catch {
                    
                }
            }
        }
    }
    func addSet(for fullExercise: FullTemplateExercise) {
        if let idx = fullExercises.firstIndex(where: { $0 == fullExercise }) {
            withAnimation(.snappy){
                fullExercises[idx].templateExerciseSets.addSet()
            }
        }
    }
    func updateSetType(for set: inout TemplateExerciseSet, to newType: SetType) {
        set.setType = newType
    }
    func updateSetWeight(for set: inout TemplateExerciseSet, to newWeight: Double) {
        set.weight = newWeight
    }
    func updateSetReps(for set: inout TemplateExerciseSet, to newReps: TemplateExerciseSet.RepType) {
        set.repType = newReps
    }
    func toggleSetType(for set: inout TemplateExerciseSet) {
        let previousType = set.repType
        switch previousType {
        case .reps(let reps):
            set.repType = .range(reps, nil)
        case .range(let lowerBound, _):
            set.repType = .reps(lowerBound)
        }
    }
}


