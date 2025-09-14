//
//  AppDatabase+WE.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/30/25.
//
import GRDB
extension AppDatabase {
    func getExerciseSets(for workoutExerciseId: Int64) async throws -> [ExerciseSetRecord] {
        return try await reader.read { db in
            try ExerciseSetRecord
                .filter {$0.workoutExerciseId == workoutExerciseId}
                .order(\.order.asc)
                .fetchAll(db)
        }
    }
    
    func deleteWorkoutExercise(_ workoutExercise: WorkoutExerciseRecord) async throws {
        return try await dbWriter.write { db in
            try workoutExercise.delete(db)
        }
    }
    func updateWorkoutExercise(_ exercise: WorkoutExerciseRecord) async throws -> WorkoutExerciseRecord {
        try await dbWriter.write { db in
            let mutable = exercise
            try mutable.update(db)
            return mutable
        }
    }
}
