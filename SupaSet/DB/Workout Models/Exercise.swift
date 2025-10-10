//
//  Exercise.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//


import GRDB
import Foundation
enum Force: String, Codable, CaseIterable, DatabaseValueConvertible {
    case `static` = "static"
    case pull = "pull"
    case push = "push"
}

enum Level: String, Codable, CaseIterable, DatabaseValueConvertible {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case expert = "expert"
}

enum Mechanic: String, Codable, CaseIterable, DatabaseValueConvertible {
    case isolation = "isolation"
    case compound = "compound"
}

enum Equipment: String, Codable, CaseIterable, DatabaseValueConvertible {
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

enum Category: String, Codable, CaseIterable, DatabaseValueConvertible {
    case powerlifting = "powerlifting"
    case strength = "strength"
    case stretching = "stretching"
    case cardio = "cardio"
    case olympicWeightlifting = "olympic weightlifting"
    case strongman = "strongman"
    case plyometrics = "plyometrics"
}
// MARK: - Main Exercise Table
struct Exercise: Codable, FetchableRecord, MutablePersistableRecord, Equatable {
    var id: String
    var name: String
    var force: Force?
    var level: Level
    var mechanic: Mechanic?
    var equipment: Equipment?
    var category: Category
    var frequency: Int?
    static let databaseTableName = "exercises"
    
    // Define columns
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let force = Column(CodingKeys.force)
        static let level = Column(CodingKeys.level)
        static let mechanic = Column(CodingKeys.mechanic)
        static let equipment = Column(CodingKeys.equipment)
        static let category = Column(CodingKeys.category)
    }
    init(exercise: ExerciseJSON) {
        self.id = exercise.id
        self.name = exercise.name
        self.force = exercise.force
        self.level = exercise.level
        self.mechanic = exercise.mechanic
        self.equipment = exercise.equipment
        self.category = exercise.category
        self.frequency = exercise.frequency
    }
    init(id: String, name: String, force: Force?, level: Level, mechanic: Mechanic?, equipment: Equipment?, category: Category, frequency: Int?) {
        self.id = id
        self.name = name
        self.force = force
        self.level = level
        self.mechanic = mechanic
        self.equipment = equipment
        self.category = category
        self.frequency = frequency
    }
}

// MARK: - Muscle Groups
enum MuscleGroup: String, Codable, CaseIterable, DatabaseValueConvertible {
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

// MARK: - Exercise Primary Muscles Junction Table
struct ExercisePrimaryMuscle: Codable, FetchableRecord, MutablePersistableRecord {
    var exerciseId: String
    var muscleGroup: MuscleGroup
    
    static let databaseTableName = "exercise_primary_muscles"
    
    enum Columns {
        static let exerciseId = Column(CodingKeys.exerciseId)
        static let muscleGroup = Column(CodingKeys.muscleGroup)
    }
}

// MARK: - Exercise Secondary Muscles Junction Table
struct ExerciseSecondaryMuscle: Codable, FetchableRecord, MutablePersistableRecord {
    var exerciseId: String
    var muscleGroup: MuscleGroup
    
    static let databaseTableName = "exercise_secondary_muscles"
    
    enum Columns {
        static let exerciseId = Column(CodingKeys.exerciseId)
        static let muscleGroup = Column(CodingKeys.muscleGroup)
    }
}

// MARK: - Exercise Instructions Table
struct ExerciseInstruction: Codable, FetchableRecord, MutablePersistableRecord {
    var id: Int64?
    var exerciseId: String
    var stepNumber: Int
    var instruction: String
    
    static let databaseTableName = "exercise_instructions"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let exerciseId = Column(CodingKeys.exerciseId)
        static let stepNumber = Column(CodingKeys.stepNumber)
        static let instruction = Column(CodingKeys.instruction)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

// MARK: - Exercise Images Table
struct ExerciseImage: Codable, FetchableRecord, MutablePersistableRecord {
    var id: Int64?
    var exerciseId: String
    var imageUrl: String
    var orderIndex: Int
    
    static let databaseTableName = "exercise_images"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let exerciseId = Column(CodingKeys.exerciseId)
        static let imageUrl = Column(CodingKeys.imageUrl)
        static let orderIndex = Column(CodingKeys.orderIndex)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
// MARK: - Relationships and Helper Methods
extension Exercise {
    static let primaryMuscles = hasMany(ExercisePrimaryMuscle.self)
    static let secondaryMuscles = hasMany(ExerciseSecondaryMuscle.self)
    static let instructions = hasMany(ExerciseInstruction.self)
    static let images = hasMany(ExerciseImage.self)
    
    var primaryMuscles: QueryInterfaceRequest<ExercisePrimaryMuscle> {
        request(for: Exercise.primaryMuscles)
    }
    
    var secondaryMuscles: QueryInterfaceRequest<ExerciseSecondaryMuscle> {
        request(for: Exercise.secondaryMuscles)
    }
    
    var instructions: QueryInterfaceRequest<ExerciseInstruction> {
        request(for: Exercise.instructions).order(ExerciseInstruction.Columns.stepNumber)
    }
    
    var images: QueryInterfaceRequest<ExerciseImage> {
        request(for: Exercise.images).order(ExerciseImage.Columns.orderIndex)
    }
}

extension ExercisePrimaryMuscle {
    static let exercise = belongsTo(Exercise.self)
    var exercise: QueryInterfaceRequest<Exercise> {
        request(for: ExercisePrimaryMuscle.exercise)
    }
}

extension ExerciseSecondaryMuscle {
    static let exercise = belongsTo(Exercise.self)
    var exercise: QueryInterfaceRequest<Exercise> {
        request(for: ExerciseSecondaryMuscle.exercise)
    }
}

extension ExerciseInstruction {
    static let exercise = belongsTo(Exercise.self)
    var exercise: QueryInterfaceRequest<Exercise> {
        request(for: ExerciseInstruction.exercise)
    }
}

extension ExerciseImage {
    static let exercise = belongsTo(Exercise.self)
    var exercise: QueryInterfaceRequest<Exercise> {
        request(for: ExerciseImage.exercise)
    }
}

struct ExerciseRowDetail: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var force: Force?
    var level: Level
    var equipment: Equipment?
    var primaryMuscles: [MuscleGroup]
    var category: Category
    var frequency: Int?
}
struct ExerciseJSON: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var force: Force?
    var level: Level
    var mechanic: Mechanic?
    var equipment: Equipment?
    var primaryMuscles: [MuscleGroup]
    var secondaryMuscles: [MuscleGroup]
    var instructions: [String]
    var category: Category
    var images: [String]
    var frequency : Int?
    static func == (lhs: ExerciseJSON, rhs: ExerciseJSON) -> Bool {
        return lhs.id == rhs.id
    }
    static var sample: ExerciseJSON {
        ExerciseJSON(
            id: "deadlift",
            name: "Deadlift",
            force: .pull,
            level: .intermediate,
            mechanic: .compound,
            equipment: .barbell,
            primaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
            secondaryMuscles: [MuscleGroup.lowerBack, MuscleGroup.traps, MuscleGroup.forearms],
            instructions: [
                "Stand with feet hip-width apart, bar over mid-foot",
                "Bend at hips and knees to grip the bar",
                "Keep chest up and back straight",
                "Drive through heels to lift the bar",
                "Stand tall with shoulders back",
                "Lower the bar with control"
            ],
            category: .powerlifting,
            images: ["deadlift-1.jpg", "deadlift-2.jpg"],
            frequency: 1
        )
    }
}
struct ExerciseFTS: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "exercise_fts"
    var id: Int64?
    var name: String
    static func match(_ pattern: FTS5Pattern) -> SQLSpecificExpressible {
            return Column("name").match(pattern) // GRDB convenience for matching against the default column(s)
            // Or explicitly: return Column("name").match(pattern)
            // Or if multiple columns: return Table(databaseTableName).match(pattern)
         }
}
