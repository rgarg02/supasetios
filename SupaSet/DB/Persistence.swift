//
//  Persistence.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import Foundation
import GRDB
import OSLog

extension AppDatabase {
    /// The database for the application
    static let shared = makeShared()
    
    private static func makeShared() -> AppDatabase {
        do {
            // Apply recommendations from
            // <https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/databaseconnections>
            
            // Create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            // Open or create the database
            let databaseURL = directoryURL.appendingPathComponent("store.sqlite")
            let config = AppDatabase.makeConfiguration()
            let dbPool = try DatabasePool(path: databaseURL.path, configuration: config)
            
            // Create the AppDatabase
            let appDatabase = try AppDatabase(dbPool)
            appDatabase.importExercisesFromJSONIfNeeded()
            // Populate the database with exercises from JSON if empty,
            // otherwise fall back to creating sample exercises if JSON import fails.
            
            return appDatabase
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
    
    /// Creates an empty database for SwiftUI previews
    static func empty() -> AppDatabase {
        // Connect to an in-memory database
        // See https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/databaseconnections
        let dbQueue = try! DatabaseQueue(configuration: AppDatabase.makeConfiguration())
        return try! AppDatabase(dbQueue)
    }
    
    /// Creates a database full of sample exercises for SwiftUI previews
    static func withSampleData() -> AppDatabase {
        let appDatabase = empty()
        try! appDatabase.createSampleExercisesIfEmpty()
        return appDatabase
    }
    static func withTemplates() -> AppDatabase {
        let appDatabase = withStrengthExercises()
        try! appDatabase.dbWriter.write({ db in
            for i in 0..<3 {
                var template = WorkoutTemplate(name: "Push Day \(i)", notes: "PUSHHH!!")
                template = try template.inserted(db)
                for i in 0..<6 {
                    let exercise = try! Exercise.fetchAll(db).randomElement()!
                    var templateExercise = TemplateExercise(templateId: template.id, exerciseID: exercise.id, order: i, notes: nil)
                    templateExercise = try templateExercise.inserted(db)
                    for i in 0..<Int.random(in: 2...4){
                        let repType = Int.random(in: 0...1) == 0 ? TemplateExerciseSet.RepType.range(Int.random(in: 5...8), Int.random(in: 8...12)) : TemplateExerciseSet.RepType.reps(Int.random(in: 5...8))
                        var templateSet = TemplateExerciseSet(templateExerciseId: templateExercise.id, repType: repType, weight: Double.random(in: 40...100), type: .working, order: i)
                        try templateSet.insert(db)
                    }
                }
            }
        })
        return appDatabase
    }
    /// Creates a database with custom exercise data for SwiftUI previews
    static func withCustomData(_ exercises: [(exercise: Exercise, primaryMuscles: [MuscleGroup], secondaryMuscles: [MuscleGroup], instructions: [String], imageUrls: [String])]) -> AppDatabase {
        let appDatabase = empty()
        try! appDatabase.importExercises(exercises)
        return appDatabase
    }
    
    /// Creates a database with a specific exercise for SwiftUI previews
    static func withExercise(_ exercise: Exercise, primaryMuscles: [MuscleGroup] = [], secondaryMuscles: [MuscleGroup] = [], instructions: [String] = [], imageUrls: [String] = []) -> AppDatabase {
        let appDatabase = empty()
        let exerciseData = [(exercise: exercise, primaryMuscles: primaryMuscles, secondaryMuscles: secondaryMuscles, instructions: instructions, imageUrls: imageUrls)]
        try! appDatabase.importExercises(exerciseData)
        return appDatabase
    }
    private func insertWorkoutWithId(workoutId: Int64? = nil) throws -> WorkoutRecord{
        _ = try dbWriter.write { db in
            try WorkoutRecord(id: 69, name: "Previous Workout", creationDate: Date().addingTimeInterval(-6000), endDate: Date().addingTimeInterval(-5000), notes: "Previous workout notes")
                .inserted(db)
        }
        return try dbWriter.write { db in
            try WorkoutRecord(id: workoutId, name: "Populated Workout", notes: "GO TO FAILURE!!")
                .inserted(db)
        }
        
    }
    private func insertRandomExercises(_ workout: WorkoutRecord, workoutExerciseId: Int64? = nil) throws {
        let id = workout.id!
        try dbWriter.write { db in
            for i in 0..<3 {
                let exercise = try! Exercise.fetchAll(db).randomElement()!
                var workoutExercise = WorkoutExerciseRecord(id: workoutExerciseId != nil && i == 0 ? workoutExerciseId: Int64.random(in: 3...100) ,workoutId: id, exerciseID: exercise.id, order: i, notes: nil)
                workoutExercise = try workoutExercise
                    .inserted(db)
                var workoutExercisePrev = WorkoutExerciseRecord(workoutId: 69, exerciseID: exercise.id, order: i, notes: nil)
                workoutExercisePrev = try workoutExercisePrev
                    .inserted(db)
                for i in 0..<3 {
                    let exerciseSet = ExerciseSetRecord(workoutExerciseId: workoutExercise.id!, reps: Int.random(in: 8...12), weight: Double.random(in: 10...100), type: .working, order: i, isDone: false)
                    try exerciseSet.insert(db)
                    let exerciseSetPrev = ExerciseSetRecord(workoutExerciseId: workoutExercisePrev.id!, reps: Int.random(in: 8...12), weight: Double.random(in: 10...100), type: .working, order: i, isDone: true)
                    try exerciseSetPrev.insert(db)
                }
            }
        }
    }
    /// Returns an in-memory repository that contains one player,
    /// for previews and tests.
    ///
    /// - parameter workoutId: The ID of the inserted workout.
    static func workoutWithPopulatedExercise(workoutId: Int64? = nil, workoutExerciseId: Int64? = nil) -> AppDatabase {
        let repo = self.withStrengthExercises()
        let workout = try! repo.insertWorkoutWithId(workoutId: workoutId)
        try! repo.insertRandomExercises(workout, workoutExerciseId: workoutExerciseId)
        return repo
    }
    
    static func completedWorkouts() -> AppDatabase {
        let appDatabase = self.withStrengthExercises()
        _ = try! appDatabase.dbWriter.write { db in
            for i in 0..<10 {
                let creationDate = Date().addingTimeInterval(TimeInterval(-86400*i - 3600))
                let endDate = Date().addingTimeInterval(TimeInterval(-86400*i))
                let workout = try WorkoutRecord(name: "Workout \(i)", creationDate: creationDate, modificationDate: endDate, endDate: endDate, notes: "Workout notes \(i)").inserted(db)
                for i in 0..<Int.random(in: 3...6) {
                    let exerciseId = try Exercise.fetchAll(db).randomElement()?.id
                    let exercise = try WorkoutExerciseRecord(workoutId: workout.id!, exerciseID: exerciseId!, order: i, notes: "exercise notes \(i)").inserted(db)
                    for i in 0..<Int.random(in: 2...4) {
                        let setType = SetType.allCases.randomElement()!
                        _ = try ExerciseSetRecord(workoutExerciseId: exercise.id!, reps: Int.random(in: 8...12), weight: Double.random(in: 30...40), type: setType, order: i, isDone: true).inserted(db)
                    }
                }
            }
        }
        return appDatabase
    }
}

// MARK: - Initial Data Import

// MARK: - Preview Helpers

extension AppDatabase {
    /// Creates a database with strength training exercises for previews
    static func withStrengthExercises() -> AppDatabase {
        let strengthExercises = [
            (
                exercise: Exercise(
                    id: "deadlift-2",
                    name: "Deadlifts",
                    force: .pull,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .barbell,
                    category: .powerlifting,
                    frequency: 1
                ),
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
                imageUrls: ["deadlift-1.jpg", "deadlift-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "deadlift",
                    name: "Deadlift",
                    force: .pull,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .barbell,
                    category: .powerlifting,
                    frequency: 1
                ),
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
                imageUrls: ["deadlift-1.jpg", "deadlift-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "overhead-press",
                    name: "Overhead Press",
                    force: .push,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .barbell,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.shoulders],
                secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Hold bar at shoulder height with palms facing forward",
                    "Press the bar straight up overhead",
                    "Lower the bar back to shoulder height with control"
                ],
                imageUrls: ["overhead-press-1.jpg", "overhead-press-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "barbell-row",
                    name: "Barbell Row",
                    force: .pull,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .barbell,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.middleBack, MuscleGroup.lats],
                secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
                instructions: [
                    "Stand with feet hip-width apart, holding barbell",
                    "Hinge at hips, keeping back straight",
                    "Pull bar to lower chest/upper abdomen",
                    "Lower bar with control"
                ],
                imageUrls: ["barbell-row-1.jpg", "barbell-row-2.jpg"]
            )
        ]
        
        return withCustomData(strengthExercises)
    }
    
    /// Creates a database with bodyweight exercises for previews
    static func withBodyweightExercises() -> AppDatabase {
        let bodyweightExercises = [
            (
                exercise: Exercise(
                    id: "push-up",
                    name: "Push-up",
                    force: .push,
                    level: .beginner,
                    mechanic: .compound,
                    equipment: .bodyOnly,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.chest],
                secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
                instructions: [
                    "Start in plank position with hands shoulder-width apart",
                    "Lower your body until chest nearly touches the floor",
                    "Push back up to starting position",
                    "Keep your body in a straight line throughout"
                ],
                imageUrls: ["pushup-1.jpg", "pushup-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "bodyweight-squat",
                    name: "Bodyweight Squat",
                    force: .push,
                    level: .beginner,
                    mechanic: .compound,
                    equipment: .bodyOnly,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.quadriceps],
                secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Lower your body by bending at hips and knees",
                    "Keep chest up and weight on heels",
                    "Push through heels to return to starting position"
                ],
                imageUrls: ["bodyweight-squat-1.jpg", "bodyweight-squat-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "plank",
                    name: "Plank",
                    force: .static,
                    level: .beginner,
                    mechanic: .isolation,
                    equipment: .bodyOnly,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.abdominals],
                secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.glutes],
                instructions: [
                    "Start in push-up position",
                    "Lower to forearms, keeping elbows under shoulders",
                    "Keep body in straight line from head to heels",
                    "Hold position while breathing normally"
                ],
                imageUrls: ["plank-1.jpg"]
            )
        ]
        
        return withCustomData(bodyweightExercises)
    }
    
    /// Creates a database with cardio exercises for previews
    static func withCardioExercises() -> AppDatabase {
        let cardioExercises = [
            (
                exercise: Exercise(
                    id: "jumping-jacks",
                    name: "Jumping Jacks",
                    force: nil,
                    level: .beginner,
                    mechanic: nil,
                    equipment: .bodyOnly,
                    category: .cardio,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.calves],
                secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.quadriceps],
                instructions: [
                    "Stand with feet together and arms at sides",
                    "Jump while spreading legs and raising arms overhead",
                    "Jump back to starting position",
                    "Repeat at a steady pace"
                ],
                imageUrls: ["jumping-jacks-1.jpg", "jumping-jacks-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "burpees",
                    name: "Burpees",
                    force: .push,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .bodyOnly,
                    category: .cardio,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.chest, MuscleGroup.quadriceps],
                secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps, MuscleGroup.calves],
                instructions: [
                    "Start in standing position",
                    "Drop into squat position with hands on floor",
                    "Jump feet back into plank position",
                    "Do a push-up",
                    "Jump feet back to squat position",
                    "Jump up with arms overhead"
                ],
                imageUrls: ["burpees-1.jpg", "burpees-2.jpg", "burpees-3.jpg"]
            )
        ]
        
        return withCustomData(cardioExercises)
    }
    
    /// Creates a database with stretching exercises for previews
    static func withStretchingExercises() -> AppDatabase {
        let stretchingExercises = [
            (
                exercise: Exercise(
                    id: "hamstring-stretch",
                    name: "Hamstring Stretch",
                    force: .static,
                    level: .beginner,
                    mechanic: .isolation,
                    equipment: .bodyOnly,
                    category: .stretching,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.hamstrings],
                secondaryMuscles: [MuscleGroup.calves],
                instructions: [
                    "Sit on the floor with one leg extended",
                    "Bend the other leg and place foot against inner thigh",
                    "Reach forward toward your toes",
                    "Hold the stretch and breathe deeply",
                    "Switch legs and repeat"
                ],
                imageUrls: ["hamstring-stretch-1.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "shoulder-stretch",
                    name: "Shoulder Stretch",
                    force: .static,
                    level: .beginner,
                    mechanic: .isolation,
                    equipment: .bodyOnly,
                    category: .stretching,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.shoulders],
                secondaryMuscles: [MuscleGroup.chest],
                instructions: [
                    "Bring one arm across your body",
                    "Use the other arm to gently pull it closer",
                    "Hold the stretch",
                    "Switch arms and repeat"
                ],
                imageUrls: ["shoulder-stretch-1.jpg"]
            )
        ]
        
        return withCustomData(stretchingExercises)
    }
}

extension AppDatabase {
    func importExercisesFromJSONIfNeeded(fileName: String = "exercises") {
        // Check if import has already been done
        guard !UserDefaults.standard.bool(forKey: initialImportCompletedKey) else {
            logger.info("Initial exercise import already completed. Skipping.")
            return
        }
        
        logger.info("Starting initial exercise import from \(fileName).json...")
        
        // 1. Find and load JSON data
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            logger.error("Failed to find \(fileName).json in bundle.")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            logger.error("Failed to load data from \(fileName).json.")
            return
        }
        
        // 2. Decode JSON into the original Exercise models
        let decoder = JSONDecoder()
        guard let exercises = try? decoder.decode([ExerciseJSON].self, from: data) else {
            logger.error("Failed to decode \(fileName).json.")
            return
        }
        
        guard !exercises.isEmpty else {
            logger.warning("\(fileName).json is empty or decoding resulted in an empty array.")
            return
        }
        
        // 3. Insert data into the database within a transaction
        do {
            try dbWriter.write { db in
                for exercise in exercises {
                    // Create and insert the main exercise record
                    var exerciseRecord = Exercise(exercise: exercise)
                    try exerciseRecord.insert(db)
                    
                    // Insert related data
                    for muscle in exercise.primaryMuscles {
                        var relation = ExercisePrimaryMuscle(exerciseId: exercise.id, muscleGroup: muscle)
                        try relation.insert(db)
                    }
                    for muscle in exercise.secondaryMuscles {
                        var relation = ExerciseSecondaryMuscle(exerciseId: exercise.id, muscleGroup: muscle)
                        try relation.insert(db)
                    }
                    for (index, instructionText) in exercise.instructions.enumerated() {
                        var relation = ExerciseInstruction(exerciseId: exercise.id, stepNumber: index, instruction: instructionText)
                        try relation.insert(db)
                    }
                    for (index, imageUrl) in exercise.images.enumerated() {
                        var relation = ExerciseImage(exerciseId: exercise.id, imageUrl: imageUrl, orderIndex: index)
                        try relation.insert(db)
                    }
                }
            }
            // Mark import as complete on success
            UserDefaults.standard.set(true, forKey: initialImportCompletedKey)
            logger.info("Successfully imported \(exercises.count) exercises into the database.")
            
        } catch {
            logger.error("Failed to import exercises into database: \(error.localizedDescription)")
            // Consider rolling back or cleaning up potentially partial data if needed,
            // though the transaction should handle atomicity.
            // Reset the flag so it can try again next time.
            UserDefaults.standard.set(false, forKey: initialImportCompletedKey)
        }
    }
}
