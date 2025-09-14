//  
//  AppDatabase+ExerciseSets.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/27/25.
//

import GRDB

extension AppDatabase {
    /// Fetch all sets for a given workoutExerciseId
    func exerciseSets(for workoutExerciseId: Int64) async throws -> [ExerciseSetRecord] {
        try await dbWriter.read { db in
            try ExerciseSetRecord
                .filter(ExerciseSetRecord.Columns.workoutExerciseId == workoutExerciseId)
                .order(ExerciseSetRecord.Columns.order)
                .fetchAll(db)
        }
    }
    func addSet(for workoutExerciseId: Int64) async throws {
        try await dbWriter.write { db in
            if let exercise = try WorkoutExerciseRecord.filter({$0.id == workoutExerciseId}).fetchOne(db) {
                let order = try exercise.exerciseSets.fetchCount(db)
                let previousSet = try exercise.exerciseSets.order(\.order.desc).fetchOne(db)
                let set = ExerciseSetRecord(workoutExerciseId: exercise.id!, reps: previousSet?.reps ?? 0, weight: previousSet?.weight ?? 0, type: previousSet?.setType ?? .working, order: order, isDone: false)
                try set.insert(db)
            }else {
                throw DatabaseError(message: "Could not find workout exercise with id: \(workoutExerciseId)")
            }
        }
    }
    func addSet(for exercise: WorkoutExerciseRecord) async throws {
        try await dbWriter.write { db in
            let order = try exercise.exerciseSets.fetchCount(db)
            let previousSet = try exercise.exerciseSets.order(\.order.desc).fetchOne(db)
            let set = ExerciseSetRecord(workoutExerciseId: exercise.id!, reps: previousSet?.reps ?? 0, weight: previousSet?.weight ?? 0, type: previousSet?.setType ?? .working, order: order, isDone: false)
            try set.insert(db)
        }
    }
    /// Insert a new set
    func addSet(_ set: ExerciseSetRecord) async throws -> ExerciseSetRecord {
        try await dbWriter.write { db in
            var mutable = set
            try mutable.insert(db)
            return mutable
        }
    }

    /// Save (update) a single set
    func updateExerciseSet(_ set: ExerciseSetRecord) async throws {
        try await dbWriter.write { db in
            let mutable = set
            try mutable.update(db)
        }
    }

    /// Delete a set and re-order the rest
    func deleteExerciseSet(_ set: ExerciseSetRecord) async throws {
        let workoutExerciseId = set.workoutExerciseId
        let targetOrder = set.order
        
        try await dbWriter.write { db in
            // 1. Delete the targeted set
            try set.delete(db)
            
            // 2. Update orders using GRDB's query interface
            try ExerciseSetRecord
                .filter(ExerciseSetRecord.Columns.workoutExerciseId == workoutExerciseId)
                .filter(ExerciseSetRecord.Columns.order > targetOrder)
                .updateAll(db, ExerciseSetRecord.Columns.order.set(to: ExerciseSetRecord.Columns.order - 1))
        }
    }
}
