//
//  FindExercisesTool.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/5/25.
//

import FoundationModels
import SwiftUI

@available(iOS 26, *)
@Observable
final class FindExercisesTool: Tool {
    let name = "findExercisesTool"
    let description = "Fetches exercise IDs from the database for the selected muscle groups."
    let appDatabase: AppDatabase
    init(appDatabase: AppDatabase) {
        self.appDatabase = appDatabase
    }
    @Generable
    struct Arguments {
        @Guide(description: "This is the muscle groups for the exercises to look for")
        let muscleGroups: [FindExercisesTool.MuscleGroup]
        @Guide(description: "This is the level of difficulty for the exercises to look for. Dont set if not mentioned.")
        let level: Level?
        @Guide(description: "This is the equipment available for the user, dont set if none")
        let equipment: Equipment?
        @Guide(description: "Type of workout. Dont set if not mentioned")
        let category: Category?
    }
    @Generable
    enum Level: String {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case expert = "expert"
    }
    @Generable
    enum Equipment: String {
        case medicineBall = "medicine ball"
        case dumbbell = "dumbbell"
        case bodyOnly = "body only"
        case bands = "bands"
        case kettlebells = "kettlebells"
        case foamRoll = "foam roll"
        case cable = "cable"
        case machine = "machine"
        case barbell = "barbell"
        case exerciseBall = "exercise ball"
        case ezCurlBar = "e-z curl bar"
        case other = "other"
    }
    @Generable
    enum Category: String {
        case powerlifting = "powerlifting"
        case strength = "strength"
        case stretching = "stretching"
        case cardio = "cardio"
        case olympicWeightlifting = "olympic weightlifting"
        case strongman = "strongman"
        case plyometrics = "plyometrics"
    }
    @Generable
    enum MuscleGroup: String {
        case abdominals = "abdominals"
        case abductors = "abductors"
        case adductors = "adductors"
        case biceps = "biceps"
        case calves = "calves"
        case chest = "chest"
        case forearms = "forearms"
        case glutes = "glutes"
        case hamstrings = "hamstrings"
        case lats = "lats"
        case lowerBack = "lower back"
        case middleBack = "middle back"
        case neck = "neck"
        case quadriceps = "quadriceps"
        case shoulders = "shoulders"
        case traps = "traps"
        case triceps = "triceps"
        case others = "others"
    }
    
    func call(arguments: Arguments) async throws -> [String] {
        return ["Ab_Roller","3_4_Sit-Up","Ab_Crunch_Machine"]
    }
}
