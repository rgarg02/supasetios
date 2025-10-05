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
    func getActivePrimaryMuscles(workoutId: Int64?) async throws -> Set<MuscleGroup> {
        return try await reader.read { db in
            let exerciseIds = try WorkoutExerciseRecord
                .filter({$0.workoutId == workoutId})
                .fetchAll(db)
                .map({$0.exerciseID})
            var primaryMuscles : Set<MuscleGroup> = []
            for exerciseId in exerciseIds {
                let activeMuscles = try ExercisePrimaryMuscle
                    .filter({$0.exerciseId == exerciseId})
                    .fetchAll(db)
                activeMuscles.forEach { primaryMuscle in
                    primaryMuscles.insert(primaryMuscle.muscleGroup)
                }
            }
            return primaryMuscles
        }
    }
    func getActiveSecondaryMuscles(workoutId: Int64?) async throws -> Set<MuscleGroup> {
        return try await reader.read { db in
            let exerciseIds = try WorkoutExerciseRecord
                .filter({$0.workoutId == workoutId})
                .fetchAll(db)
                .map({$0.exerciseID})
            var secondaryMuscles : Set<MuscleGroup> = []
            for exerciseId in exerciseIds {
                let activeMuscles = try ExerciseSecondaryMuscle
                    .filter({$0.exerciseId == exerciseId})
                    .fetchAll(db)
                activeMuscles.forEach { secondaryMuscle in
                    secondaryMuscles.insert(secondaryMuscle.muscleGroup)
                }
            }
            return secondaryMuscles
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
                var templateExerciseWithSets: [FullTemplateExercise] = []
                for templateExercise in templateExercises {
                    let sets = try templateExercise.templateSets.fetchAll(db)
                    templateExerciseWithSets.append(.init(templateExercise: templateExercise, templateExerciseSets: sets))
                }
                var workout = WorkoutRecord(name: template.name, notes: template.notes)
                try workout.insert(db)
                for templateExerciseWithSet in templateExerciseWithSets {
                    let templateExercise = templateExerciseWithSet.templateExercise
                    let templateSets = templateExerciseWithSet.templateExerciseSets
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
    func fetchPreviousSet(for currentSet: ExerciseSetRecord, in exerciseID: String) async throws -> ExerciseSetRecord? {
        return try await reader.read { db in
            let sql = """
                    SELECT es.*
                    FROM exerciseSet es
                    JOIN workoutExercise we ON we.id = es.workoutExerciseId
                    JOIN workout w ON w.id = we.workoutId
                    WHERE we.exerciseID = ?
                      AND es.id != ?
                      AND es."order" = ?
                      AND es.type = ?
                      AND w.endDate IS NOT NULL
                      AND es.isDone = 1
                    ORDER BY w.endDate DESC
                    LIMIT 1
                """
            
            // Execute the query with arguments to prevent SQL injection
            let previousSet = try ExerciseSetRecord.fetchOne(db, sql: sql, arguments: [
                exerciseID,
                currentSet.id,
                currentSet.order,
                currentSet.setType.rawValue
            ])
            return previousSet
        }
    }
    
    func fetchPreviousCalendarSets(for exerciseId: String) async throws -> [ExerciseSetRecord] {
        try await reader.read { db in
            let workoutAlias = TableAlias(name: "parentWorkout")
            let lastWorkoutExercise = try WorkoutExerciseRecord
                            .filter(WorkoutExerciseRecord.Columns.exerciseID == exerciseId)
                            .joining(required: WorkoutExerciseRecord.workout.aliased(workoutAlias))
                            .filter(workoutAlias[WorkoutRecord.Columns.endDate] != nil)
                            .order(workoutAlias[WorkoutRecord.Columns.creationDate].desc)
                            .fetchOne(db)
            return try ExerciseSetRecord
                .filter{$0.workoutExerciseId == lastWorkoutExercise?.id}
                .order(\.order)
                .fetchAll(db)
        }
    }
    func fetchPreviousCalendarSets(for exerciseId: String) throws -> [ExerciseSetRecord] {
        try reader.read { db in
            let workoutAlias = TableAlias(name: "parentWorkout")
            let lastWorkoutExercise = try WorkoutExerciseRecord
                            .filter(WorkoutExerciseRecord.Columns.exerciseID == exerciseId)
                            .joining(required: WorkoutExerciseRecord.workout.aliased(workoutAlias))
                            .filter(workoutAlias[WorkoutRecord.Columns.endDate] != nil)
                            .order(workoutAlias[WorkoutRecord.Columns.creationDate].desc)
                            .fetchOne(db)
            return try ExerciseSetRecord
                .filter{$0.workoutExerciseId == lastWorkoutExercise?.id}
                .order(\.order)
                .fetchAll(db)
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
    
    func fetchActivePrimaryMuscles(for exerciseIds: [String]) async throws -> Set<MuscleGroup> {
        return try await reader.read { db in
            var primaryMuscles : Set<MuscleGroup> = []
            for exerciseId in exerciseIds {
                let activeMuscles = try ExercisePrimaryMuscle
                    .filter({$0.exerciseId == exerciseId})
                    .fetchAll(db)
                activeMuscles.forEach { primaryMuscle in
                    primaryMuscles.insert(primaryMuscle.muscleGroup)
                }
            }
            return primaryMuscles
        }
    }
    func fetchActiveSecondaryMuscles(for exerciseIds: [String]) async throws -> Set<MuscleGroup> {
        return try await reader.read { db in
            var secondaryMuscles : Set<MuscleGroup> = []
            for exerciseId in exerciseIds {
                let activeMuscles = try ExerciseSecondaryMuscle
                    .filter({$0.exerciseId == exerciseId})
                    .fetchAll(db)
                activeMuscles.forEach { secondaryMuscle in
                    secondaryMuscles.insert(secondaryMuscle.muscleGroup)
                }
            }
            return secondaryMuscles
        }
    }
    func deleteWorkout(_ workout: WorkoutRecord) async throws {
        try await dbWriter.write { db in
            _ = try workout.delete(db)
        }
    }
    func deleteTemplate(_ template: WorkoutTemplate) async throws {
        try await dbWriter.write { db in
            _ = try template.delete(db)
        }
    }
    func saveChanges(to workout: WorkoutRecord, exercisesToDelete: [WorkoutExerciseRecord], setsToDelete: [ExerciseSetRecord], fullExercises: [FullExercise]) async throws {
        try await dbWriter.write { db in
            var workout = workout
            try workout.touch(db)
            try workout.save(db)
            for exerciseToDelete in exercisesToDelete {
                try exerciseToDelete.delete(db)
            }
            for setToDelete in setsToDelete {
                try setToDelete.delete(db)
            }
            // 2. Update existing or insert new exercises and sets
            for fullExercise in fullExercises {
                // If the exercise existed before, update it. Otherwise, insert it.
                var workoutExerciseToSave = fullExercise.workoutExercise
                workoutExerciseToSave.workoutId = workout.id // Ensure workoutId is set
                workoutExerciseToSave = try workoutExerciseToSave.saved(db)
                
                // Insert all the current sets
                for var set in fullExercise.exerciseSets {
                    set.workoutExerciseId = workoutExerciseToSave.id // Ensure the foreign key is correct
                    try set.save(db)
                }
            }
        }
    }
    func saveChanges(to template: WorkoutTemplate, exercisesToDelete: [TemplateExercise], setsToDelete: [TemplateExerciseSet], fullExercises: [FullTemplateExercise]) async throws {
        try await dbWriter.write { db in
            var template = template
            template = try template.saved(db)
            try template.touch(db)
            for exerciseToDelete in exercisesToDelete {
                try exerciseToDelete.delete(db)
            }
            for setToDelete in setsToDelete {
                try setToDelete.delete(db)
            }
            // 2. Update existing or insert new exercises and sets
            for fullExercise in fullExercises {
                var workoutExerciseToSave = fullExercise.templateExercise
                workoutExerciseToSave.templateId = template.id
                workoutExerciseToSave = try workoutExerciseToSave.saved(db)
                
                // Insert all the current sets
                for var set in fullExercise.templateExerciseSets {
                    set.templateExerciseId = workoutExerciseToSave.id // Ensure the foreign key is correct
                    try set.save(db)
                }
            }
        }
    }
}
