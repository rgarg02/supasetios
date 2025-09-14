//
//  AppDatabase+Workout.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import GRDB
enum FetchError: Error {
    case templateNotFound
}
extension AppDatabase {
    func fetchOngoingWorkout() async throws -> WorkoutRecord? {
        return try await reader.read { db in
            try WorkoutRecord
                .filter{$0.endDate == nil}
                .fetchOne(db)
        }
    }
    func startWorkout(name: String, notes: String) async throws {
        return try await dbWriter.write { db in
            let workout = WorkoutRecord(name: name, notes: notes)
            _ = try workout.inserted(db)
        }
    }
    func touch(_ workout: WorkoutRecord) async throws {
        try await dbWriter.write { db in
            var workout = workout
            try workout.touch(db)
        }
    }
    func updateWorkout(_ workout: WorkoutRecord) async throws -> WorkoutRecord {
        try await dbWriter.write { db in
            var mutableWorkout = workout
            try mutableWorkout.updateWithTimestamp(db)
            return mutableWorkout
        }
    }
        
    // ————————————————————————————————————————————————————————————————————
    
    /// - Parameters:
    ///   - exerciseIds: An array of `String` identifiers for the exercises to be added.
    ///   - workoutId: The `Int64` identifier of the workout to which the exercises will be added.
    func addExercisesToWorkout(exerciseIds: [String], to workoutId: Int64) async throws {
        try await dbWriter.write { db in
            let lastExercise = try WorkoutExerciseRecord
                .filter(WorkoutExerciseRecord.Columns.workoutId == workoutId)
                .order(WorkoutExerciseRecord.Columns.order.desc)
                .fetchOne(db)
            
            var currentOrder = (lastExercise?.order ?? -1) + 1
            
            for exerciseId in exerciseIds {
                let workoutExercise = WorkoutExerciseRecord(
                    workoutId: workoutId,
                    exerciseID: exerciseId,
                    order: currentOrder,
                    notes: nil
                )
                try workoutExercise.insert(db)
                currentOrder += 1
            }
            print("added exercises")
        }
    }
    
    func startWorkout(from templateId: Int64?) async throws {
        if let templateId {
            try await dbWriter.write { db in
                guard let template = try WorkoutTemplate.filter({$0.id == templateId}).fetchOne(db) else {
                    throw FetchError.templateNotFound
                }
                let templateExercises = try template.templateExercises.fetchAll(db)
                var templateExerciseWithSets: [TemplateExerciseWithSets] = []
                for templateExercise in templateExercises {
                    let sets = try templateExercise.templateSets.fetchAll(db)
                    templateExerciseWithSets.append(.init(templateExercise: templateExercise, templateSets: sets))
                }
                var workout = WorkoutRecord(name: template.name, notes: template.notes)
                try workout.insert(db)
                for templateExerciseWithSet in templateExerciseWithSets {
                    let templateExercise = templateExerciseWithSet.templateExercise
                    let templateSets = templateExerciseWithSet.templateSets
                    var workoutExercise = WorkoutExerciseRecord(from: templateExercise, workoutId: workout.id!)
                    workoutExercise = try workoutExercise.inserted(db)
                    for templateSet in templateSets {
                        let exerciseSet = ExerciseSetRecord(from: templateSet, workoutExerciseId: workoutExercise.id!)
                        try exerciseSet.insert(db)
                    }
                }
            }
        }
    }
    /// - Parameters:
    ///   - exerciseIds: An array of `String` identifiers for the exercises to be added.
    ///   - workoutId: The `Int64` identifier of the workout to which the exercises will be added.
    func addExercisesToWorkoutWithPreviousSets(exerciseIds: [String], to workoutId: Int64) async throws {
        try await dbWriter.write { db in
            let lastExercise = try WorkoutExerciseRecord
                .filter(WorkoutExerciseRecord.Columns.workoutId == workoutId)
                .order(WorkoutExerciseRecord.Columns.order.desc)
                .fetchOne(db)
            
            var currentOrder = (lastExercise?.order ?? -1) + 1
            
            for exerciseId in exerciseIds {
                var workoutExercise = WorkoutExerciseRecord(
                    workoutId: workoutId,
                    exerciseID: exerciseId,
                    order: currentOrder,
                    notes: nil
                )
                workoutExercise = try workoutExercise.inserted(db)
                let workoutAlias = TableAlias(name: "parentWorkout")
                let lastWorkoutExercise = try WorkoutExerciseRecord
                                .filter(WorkoutExerciseRecord.Columns.exerciseID == exerciseId)
                                .joining(required: WorkoutExerciseRecord.workout.aliased(workoutAlias))
                                .filter(workoutAlias[WorkoutRecord.Columns.endDate] != nil)
                                .filter({$0.id != workoutExercise.id})
                                .order(workoutAlias[WorkoutRecord.Columns.creationDate].desc)
                                .fetchOne(db)
                let previousSets = try ExerciseSetRecord
                    .filter{$0.workoutExerciseId == lastWorkoutExercise?.id}
                    .order(\.order)
                    .fetchAll(db)
                
                for previousSet in previousSets {
                    let copy = ExerciseSetRecord(workoutExerciseId: workoutExercise.id!, reps: previousSet.reps, weight: previousSet.weight, type: previousSet.setType, order: previousSet.order, isDone: false)
                    try copy.insert(db)
                }
                currentOrder += 1
            }
        }
    }
    
    func workoutExercises(for workoutId: Int64) async throws -> [WorkoutExerciseRecord] {
        try await dbWriter.read { db in
            try WorkoutExerciseRecord
                .filter(WorkoutExerciseRecord.Columns.workoutId == workoutId)
                .order(WorkoutExerciseRecord.Columns.order)
                .fetchAll(db)
        }
    }
    
    /// Fetches a full workout (including exercises and their sets) for a given workout ID
    func fetchFullWorkout(for workoutId: Int64) async throws -> FullWorkout? {
        return try await reader.read { db in
            // 1. Fetch the WorkoutRecord
            guard let workout = try WorkoutRecord.filter(WorkoutRecord.Columns.id == workoutId).fetchOne(db) else {
                return nil
            }
            // 2. Fetch all WorkoutExerciseRecords for the workout
            let workoutExercises = try WorkoutExerciseRecord
                .filter(WorkoutExerciseRecord.Columns.workoutId == workoutId)
                .order(WorkoutExerciseRecord.Columns.order)
                .fetchAll(db)

            // 3. For each exercise, fetch associated sets and build FullExercise
            let fullExercises: [FullExercise] = try workoutExercises.map { workoutExercise in
                let sets = try ExerciseSetRecord
                    .filter(ExerciseSetRecord.Columns.workoutExerciseId == workoutExercise.id)
                    .order(ExerciseSetRecord.Columns.order)
                    .fetchAll(db)

                return FullExercise(workoutExercise: workoutExercise, exerciseSets: sets)
            }

            // 4. Return as FullWorkout
            return FullWorkout(workout: workout, fullExercise: fullExercises)
        }
    }
}
