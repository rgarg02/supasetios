//
//  AppDatabase+WE.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/30/25.
//
import GRDB
extension AppDatabase {
    func fetchFullExercises(for template: WorkoutTemplate) async throws -> [FullTemplateExercise] {
        return try await reader.read { db in
            let workoutExercises = try TemplateExercise
                .filter({$0.templateId == template.id})
                .order(\.order)
                .fetchAll(db)
            var fullExercises : [FullTemplateExercise] = []
            for workoutExercise in workoutExercises {
                let exerciseSets = try workoutExercise.templateSets.order(\.order).fetchAll(db)
                fullExercises.append(.init(templateExercise: workoutExercise, templateExerciseSets: exerciseSets))
            }
            return fullExercises
        }
    }
    func fetchFullExercises(for workout: WorkoutRecord) async throws -> [FullExercise] {
        return try await reader.read { db in
            let workoutExercises = try WorkoutExerciseRecord
                .filter({$0.workoutId == workout.id})
                .order(\.order)
                .fetchAll(db)
            var fullExercises : [FullExercise] = []
            for workoutExercise in workoutExercises {
                let exerciseSets = try workoutExercise.exerciseSets.order(\.order).fetchAll(db)
                fullExercises.append(.init(workoutExercise: workoutExercise, exerciseSets: exerciseSets))
            }
            return fullExercises
        }
    }
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
    func replaceWorkoutExercise(_ exercise: WorkoutExerciseRecord, with exerciseID: String) async throws {
        try await dbWriter.write { db in
            var mutable = exercise
            mutable.exerciseID = exerciseID
            try mutable.exerciseSets.deleteAll(db)
            let previousSets = try self.fetchPreviousCalendarSets(for: exerciseID)
            for previousSet in previousSets {
                let copy = ExerciseSetRecord(previousSet, workoutExerciseId: mutable.id)
                try copy.insert(db)
            }
            try mutable.save(db)
        }
    }
}
