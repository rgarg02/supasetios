//
//  WorkoutExerciseRequest.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/29/25.
//

import GRDB
import GRDBQuery

struct WorkoutExercisesWithSetsRequest: ValueObservationQueryable {
    var workoutId: Int64?
    static var defaultValue: [WorkoutExerciseWithSets] {[]}
    
    func fetch(_ db: Database) throws -> [WorkoutExerciseWithSets] {
        var output: [WorkoutExerciseWithSets] = []
        let exercises = try WorkoutExerciseRecord
            .filter({$0.workoutId == workoutId})
            .order(\.order)
            .fetchAll(db)
        for exercise in exercises {
            let sets = try ExerciseSetRecord
                .filter({$0.workoutExerciseId == exercise.id})
                .order(\.order)
                .fetchAll(db)
            output.append(.init(workoutExercise: exercise, exerciseSets: sets))
        }
        return output
    }
}
