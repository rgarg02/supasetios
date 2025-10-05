//
//  WorkoutVM.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI
import GRDB
@MainActor
@Observable
final class WorkoutVM {
    var workout: WorkoutRecord
    var fullExercises: [FullExercise] = [] {
        didSet {
            if oldValue != fullExercises {
                print("new set")
            }
        }
    }
    let appDatabase: AppDatabase
    let isNew: Bool
    
    @ObservationIgnored private var cancellable: AnyDatabaseCancellable?
    @ObservationIgnored private var deletedExercises: [WorkoutExerciseRecord] = []
    @ObservationIgnored private var deletedSets: [ExerciseSetRecord] = []
    init(workout: WorkoutRecord,appDatabase: AppDatabase, isNew: Bool = true) {
        self.workout = workout
        self.appDatabase = appDatabase
        self.isNew = isNew
        if isNew {
            observeExercises()
        }else {
            fetchFullExercises()
        }
    }
    private func observeExercises() {
        // We observe all players, sorted according to `ordering`.
        let observation = ValueObservation.tracking { [workout] db in
            let workoutExercises = try WorkoutExerciseRecord
                .filter({$0.workoutId == workout.id!})
                .order(\.order)
                .fetchAll(db)
            var fullExercises : [FullExercise] = []
            for workoutExercise in workoutExercises {
                let exerciseSets = try workoutExercise.exerciseSets.order(\.order).fetchAll(db)
                fullExercises.append(.init(workoutExercise: workoutExercise, exerciseSets: exerciseSets))
            }
            return fullExercises
        }
        
        // Start observing the database.
        // Previous observation, if any, is cancelled.
        cancellable = observation.start(in: appDatabase.reader) { error in
            // Handle error
        } onChange: { [unowned self] fullExercises in
            self.fullExercises = fullExercises
        }
    }
    private func fetchFullExercises(){
        Task {
            do {
                let fetchedExercises = try await appDatabase.fetchFullExercises(for: workout)
                DispatchQueue.main.async {
                    self.fullExercises = fetchedExercises
                }
            } catch {
                
            }
        }
    }
    func updateWorkoutName(to newName: String) {
        workout.name = newName
        if isNew {
            let workout = workout
            Task {
                do {
                    _ = try await appDatabase.updateWorkout(workout)
                } catch {
                    
                }
            }
        }
    }
    func fetchActivePrimaryMuscles() async throws -> Set<MuscleGroup> {
        let exerciseIds = fullExercises.map({$0.workoutExercise.exerciseID})
        return try await appDatabase.fetchActivePrimaryMuscles(for: exerciseIds)
    }
    func fetchActiveSecondaryMuscles() async throws -> Set<MuscleGroup> {
        let exerciseIds = fullExercises.map({$0.workoutExercise.exerciseID})
        return try await appDatabase.fetchActiveSecondaryMuscles(for: exerciseIds)
    }
    func updateWorkoutNotes(to newNotes: String) {
        workout.notes = newNotes
        if isNew {
            let workout = workout
            Task {
                do {
                    _ = try await appDatabase.updateWorkout(workout)
                } catch {
                    
                }
            }
        }
    }
    // Add this method to your WorkoutVM
    func saveChanges() async throws {
        // Can't save if it's a new workout this way, this is for committing edits.
        guard !isNew else { return }
        
        try await appDatabase.saveChanges(to: workout, exercisesToDelete: deletedExercises, setsToDelete: deletedSets, fullExercises: fullExercises)
    }
    func deleteWorkout() {
        Task {
            do {
                try await appDatabase.deleteWorkout(workout)
            }
        }
    }
    func finishWorkout() {
        if isNew {
            Task { @MainActor in
                do {
                    var updatedWorkout = workout
                    updatedWorkout.endDate = Date()
                    _ = try await appDatabase.updateWorkout(updatedWorkout)
                } catch {
                    // Handle error if needed
                }
            }
        } else {
            Task {
                do {
                    if workout.endDate == nil {
                        workout.endDate = Date()
                    }
                    try await saveChanges()
                } catch {
                    
                }
            }
        }
    }
    func deleteExercise(_ exercise: WorkoutExerciseRecord) {
        withAnimation(.snappy) {
            fullExercises.removeAll(where: {$0.workoutExercise == exercise})
        }
        if isNew {
            Task{ @MainActor in
                do {
                    try await appDatabase.deleteWorkoutExercise(exercise)
                } catch {
                }
            }
        }else {
            deletedExercises.append(exercise)
        }
    }
    func replaceExercise(_ exercise: WorkoutExerciseRecord, for exerciseID: String) {
        if isNew {
            Task{ @MainActor in
                do {
                    _ = try await appDatabase.replaceWorkoutExercise(exercise, with: exerciseID)
                } catch {
                    // TODO:
                }
            }
        }else{
            if let idx = fullExercises.firstIndex(where: { $0.workoutExercise == exercise }) {
                Task { @MainActor in
                    let previousSets = try await appDatabase.fetchPreviousCalendarSets(for: exerciseID)
                    let copySets: [ExerciseSetRecord] = previousSets.map{ExerciseSetRecord($0, workoutExerciseId: exercise.id)}
                    deletedSets.append(contentsOf: fullExercises[idx].exerciseSets)
                        withAnimation(.snappy) {
                            fullExercises[idx].workoutExercise.exerciseID = exerciseID
                            fullExercises[idx].exerciseSets = copySets
                        }
                }
            }
        }
    }
    func addExercisesToWorkout(exerciseIds: [String]) {
        if isNew {
            Task{ @MainActor in
                do {
                    try await appDatabase.addExercisesToWorkoutWithPreviousSets(exerciseIds: exerciseIds, to: workout.id!)
                } catch {
                    // Handle error if needed
                }
            }
        } else {
            Task {
                for exerciseId in exerciseIds {
                    do {
                        let previousSets = try await appDatabase.fetchPreviousCalendarSets(for: exerciseId)
                        let workoutExercise = WorkoutExerciseRecord(exerciseID: exerciseId, order: fullExercises.count, notes: nil)
                        Task {@MainActor in
                            fullExercises.append(.init(workoutExercise: workoutExercise, exerciseSets: previousSets))
                        }
                    } catch {
                        
                    }
                }
            }
        }
    }
    func addSet(for fullExercise: FullExercise) {
        let previousSet = fullExercise.exerciseSets.last
        var newSet: ExerciseSetRecord
        newSet = ExerciseSetRecord(workoutExerciseId: fullExercise.workoutExercise.id, reps: previousSet?.reps ?? 0, weight: previousSet?.weight ?? 0, type: previousSet?.setType ?? .working, rpe: previousSet?.rpe, notes: previousSet?.notes, order: fullExercise.exerciseSets.count, isDone: false)
        if let idx = fullExercises.firstIndex(where: { $0 == fullExercise }) {
            withAnimation(.snappy){
                fullExercises[idx].exerciseSets.append(newSet)
            }
        }
        let workoutExerciseId = fullExercise.workoutExercise.id
        if isNew, workoutExerciseId != nil{
            Task {
                do {
                    _ = try await appDatabase.addSet(newSet)
                } catch {
                    // handle error
                }
            }
        }
    }
    func updateSetType(for set: inout ExerciseSetRecord, to newType: SetType) {
        set.setType = newType
        var mutableSet = set
        if isNew {
            Task {
                mutableSet.setType = newType
                do {
                    try await appDatabase.updateExerciseSet(mutableSet)
                } catch {
                    // TODO: Add proper error handling
                    print("Failed to update set type: \(error.localizedDescription)")
                }
            }
        }
    }
    func updateSetWeight(for set: inout ExerciseSetRecord, to newWeight: Double) {
        set.weight = newWeight
        var mutableSet = set
        if isNew {
            Task {
                mutableSet.weight = newWeight
                do {
                    try await appDatabase.updateExerciseSet(mutableSet)
                } catch {
                    // TODO: Add proper error handling
                    print("Failed to update set type: \(error.localizedDescription)")
                }
            }
        }
    }
    func updateSetReps(for set: inout ExerciseSetRecord, to newReps: Int) {
        set.reps = newReps
        var mutableSet = set
        if isNew {
            Task {
                mutableSet.reps = newReps
                do {
                    try await appDatabase.updateExerciseSet(mutableSet)
                } catch {
                    // TODO: Add proper error handling
                    print("Failed to update set type: \(error.localizedDescription)")
                }
            }
        }
    }
    func toggleSetCompletion(for set: inout ExerciseSetRecord) {
        set.isDone.toggle()
        let mutableSet = set
        if isNew {
            Task {
                do {
                    try await appDatabase.updateExerciseSet(mutableSet)
                } catch {
                    // TODO: Add proper error handling
                    print("Failed to update set type: \(error.localizedDescription)")
                }
            }
        }
    }
}

