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
struct ActivePrimaryMuscleRequest: ValueObservationQueryable {
    /// How players are sorted.
    var workoutId: Int64

    static var defaultValue: Set<MuscleGroup> { [] }

    func fetch(_ db: Database) throws -> Set<MuscleGroup> {
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
struct ActiveSecondaryMusclesRequest: ValueObservationQueryable {
    /// How players are sorted.
    var workoutId: Int64

    static var defaultValue: Set<MuscleGroup> { [] }

    func fetch(_ db: Database) throws -> Set<MuscleGroup> {
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
