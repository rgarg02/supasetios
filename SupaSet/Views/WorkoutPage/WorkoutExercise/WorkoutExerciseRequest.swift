//
//  struct.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/30/25.
//

import GRDBQuery
import GRDB
// 4. Define the request struct
struct WorkoutExercisesRequest: ValueObservationQueryable {
    /// How players are sorted.
    var workoutId: Int64

    static var defaultValue: [WorkoutExerciseWithExercise] { [] }

    func fetch(_ db: Database) throws -> [WorkoutExerciseWithExercise] {
        let workoutExercises = try WorkoutExerciseRecord
            .filter{$0.workoutId == workoutId}
            .order(\.order)
            .fetchAll(db)
        var output : [WorkoutExerciseWithExercise] = try workoutExercises.map {
            let exercise = try $0.exercise.fetchOne(db)
            return WorkoutExerciseWithExercise(workoutExercise: $0, exercise: exercise)
        }
        return output
    }
}
