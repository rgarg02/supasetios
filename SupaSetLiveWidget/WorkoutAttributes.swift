//
//  WorkoutAttributes.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/6/25.
//

import Foundation
import ActivityKit
struct WorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var workoutName: String
        var exerciseName: String
        var exerciseNumber: Int
        var totalSets: Int
        var currentSetNumber: Int
        var setType: SetType
        var weight: Double
        var reps: Int
        var setCompleted: Bool
    }
    var startTime: Date
}
