//
//  WE+E.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/30/25.
//

import GRDB
import Foundation


struct WorkoutExerciseWithExercise: Equatable {
    var workoutExercise: WorkoutExerciseRecord
    var exercise: Exercise?
}
