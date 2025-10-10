//
//  AppDatabase.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//


import Foundation
import GRDB
import os.log

/// The type that provides access to the application database.
///
/// For example:
///
/// ```swift
/// // Create an empty, in-memory, AppDatabase
/// let config = AppDatabase.makeConfiguration()
/// let dbQueue = try DatabaseQueue(configuration: config)
/// let appDatabase = try AppDatabase(dbQueue)
/// ```
final class AppDatabase: Sendable {
    /// Access to the database.
    ///
    /// See <https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/databaseconnections>
    internal let dbWriter: any DatabaseWriter
    internal let initialImportCompletedKey = "initialExerciseImportCompleted"
    internal let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "GRDBManager")
    /// Creates a `AppDatabase`, and makes sure the database schema
    /// is ready.
    ///
    /// - important: Create the `DatabaseWriter` with a configuration
    ///   returned by ``makeConfiguration(_:)``.
    init(_ dbWriter: any GRDB.DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See <https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/migrations>
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/GRDB.swift/documentation/grdb/migrations#The-eraseDatabaseOnSchemaChange-Option>
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("v1") { db in
            // MARK: - Exercise
            try db.create(table: "exercises") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("force", .text) // nullable
                t.column("level", .text).notNull()
                t.column("mechanic", .text) // nullable
                t.column("equipment", .text) // nullable
                t.column("category", .text).notNull()
                t.column("frequency", .integer)
            }
            
            // Create exercise_primary_muscles junction table
            try db.create(table: "exercise_primary_muscles") { t in
                t.column("exerciseId", .text).notNull()
                t.column("muscleGroup", .text).notNull()
                t.primaryKey(["exerciseId", "muscleGroup"])
                t.foreignKey(["exerciseId"], references: "exercises", columns: ["id"], onDelete: .cascade)
            }
            
            // Create exercise_secondary_muscles junction table
            try db.create(table: "exercise_secondary_muscles") { t in
                t.column("exerciseId", .text).notNull()
                t.column("muscleGroup", .text).notNull()
                t.primaryKey(["exerciseId", "muscleGroup"])
                t.foreignKey(["exerciseId"], references: "exercises", columns: ["id"], onDelete: .cascade)
            }
            
            // Create exercise_instructions table
            try db.create(table: "exercise_instructions") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exerciseId", .text).notNull()
                t.column("stepNumber", .integer).notNull()
                t.column("instruction", .text).notNull()
                t.foreignKey(["exerciseId"], references: "exercises", columns: ["id"], onDelete: .cascade)
                t.uniqueKey(["exerciseId", "stepNumber"])
            }
            
            // Create exercise_images table
            try db.create(table: "exercise_images") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exerciseId", .text).notNull()
                t.column("imageUrl", .text).notNull()
                t.column("orderIndex", .integer).notNull()
                t.foreignKey(["exerciseId"], references: "exercises", columns: ["id"], onDelete: .cascade)
                t.uniqueKey(["exerciseId", "orderIndex"])
            }
            
            // MARK: - Workout
            
            // Create workout table
            try db.create(table: "workout") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("creationDate", .datetime).notNull()
                t.column("modificationDate", .datetime).notNull()
                t.column("endDate", .datetime) // nullable
                t.column("notes", .text).notNull()
            }
            
            // Create workoutExercise table (junction between Workout and Exercise)
            try db.create(table: "workoutExercise") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exerciseID", .text).notNull()
                t.foreignKey(["exerciseID"], references: "exercises", columns: ["id"], onDelete: .cascade)
                t.column("order", .integer).notNull()
                t.column("notes", .text) // nullable
                t.belongsTo("workout", onDelete: .cascade)
                    .notNull()
                
            }
            
            // Create exerciseSet table (details for each set within a WorkoutExercise)
            try db.create(table: "exerciseSet") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("reps", .integer).notNull()
                t.column("weight", .double).notNull()
                t.column("type", .text).notNull() // Stores SetType raw value
                t.column("rpe", .double) // nullable
                t.column("notes", .text) // nullable
                t.column("order", .integer).notNull()
                t.column("isDone", .boolean).notNull()
                t.belongsTo("workoutExercise", onDelete: .cascade)
                    .notNull()
            }
            
            // Create indexes for better performance
            try db.create(index: "idx_exercises_name", on: "exercises", columns: ["name"])
            try db.create(index: "idx_exercises_category", on: "exercises", columns: ["category"])
            try db.create(index: "idx_exercises_equipment", on: "exercises", columns: ["equipment"])
            try db.create(index: "idx_primary_muscles_muscle", on: "exercise_primary_muscles", columns: ["muscleGroup"])
            try db.create(index: "idx_secondary_muscles_muscle", on: "exercise_secondary_muscles", columns: ["muscleGroup"])
            try db.create(index: "idx_workout_creation_date", on: "workout", columns: ["creationDate"])
            try db.create(index: "idx_workoutExercise_workoutId", on: "workoutExercise", columns: ["workoutId"])
            try db.create(index: "idx_workoutExercise_exerciseID", on: "workoutExercise", columns: ["exerciseID"])
            try db.create(index: "idx_exerciseSet_workoutExerciseId", on: "exerciseSet", columns: ["workoutExerciseId"])
            
            // FTS table
            try db.create(virtualTable: "exercise_fts", using: FTS5()) { t in
                t.column("id")
                t.column("name")
                // Link the FTS table to the content table using synchronize
                t.synchronize(withTable: Exercise.databaseTableName)
                
                // Use a tokenizer that supports stemming for better search results
                t.tokenizer = .porter(wrapping: .unicode61())
            }
            // MARK: - Triggers for Exercise Frequency
            
            // Trigger to increment frequency when a workout exercise is added
            try db.execute(sql: """
                            CREATE TRIGGER increment_exercise_frequency
                            AFTER INSERT ON workoutExercise
                            FOR EACH ROW
                            BEGIN
                                UPDATE exercises 
                                SET frequency = COALESCE(frequency, 0) + 1
                                WHERE id = NEW.exerciseID;
                            END;
                            """)
            
            // Trigger to decrement frequency when a workout exercise is deleted
            try db.execute(sql: """
                            CREATE TRIGGER decrement_exercise_frequency
                            AFTER DELETE ON workoutExercise
                            FOR EACH ROW
                            BEGIN
                                UPDATE exercises 
                                SET frequency = MAX(0, COALESCE(frequency, 0) - 1)
                                WHERE id = OLD.exerciseID;
                            END;
                            """)
            
            // Trigger to handle frequency updates when exerciseID is changed
            try db.execute(sql: """
                            CREATE TRIGGER update_exercise_frequency
                            AFTER UPDATE OF exerciseID ON workoutExercise
                            FOR EACH ROW
                            WHEN OLD.exerciseID != NEW.exerciseID
                            BEGIN
                                -- Decrement frequency for the old exercise
                                UPDATE exercises 
                                SET frequency = MAX(0, COALESCE(frequency, 0) - 1)
                                WHERE id = OLD.exerciseID;
                                
                                -- Increment frequency for the new exercise
                                UPDATE exercises 
                                SET frequency = COALESCE(frequency, 0) + 1
                                WHERE id = NEW.exerciseID;
                            END;
                            """)
            // MARK: - Workout Template
            // Create WorkoutTemplate table
            try db.create(table: "workoutTemplate") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("creationDate", .datetime)
                t.column("modificationDate", .datetime)
                t.column("notes", .text).notNull()
            }

            // Create TemplateExercise table (junction between WorkoutTemplate and Exercise)
            try db.create(table: "templateExercise") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("templateId", .integer).notNull().references("workoutTemplate", onDelete: .cascade)
                t.column("exerciseID", .text).notNull().references("exercises", onDelete: .cascade)
                t.column("order", .integer).notNull()
                t.column("notes", .text)
            }

            // Create TemplateExerciseSet table
            try db.create(table: "templateExerciseSet") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("templateExerciseId", .integer).notNull().references("templateExercise", onDelete: .cascade)
                t.column("repType", .text).notNull() // Stores encoded RepType
                t.column("weight", .double)
                t.column("type", .text).notNull() // Stores SetType raw value
                t.column("rpe", .double)
                t.column("notes", .text)
                t.column("order", .integer).notNull()
            }

            // MARK: - Indexes for New Tables
            try db.create(index: "idx_templateExercise_templateId", on: "templateExercise", columns: ["templateId"])
            try db.create(index: "idx_templateExercise_exerciseID", on: "templateExercise", columns: ["exerciseID"])
            try db.create(index: "idx_templateExerciseSet_templateExerciseId", on: "templateExerciseSet", columns: ["templateExerciseId"])


        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration("v2") { db in
        //     // Add new columns or tables
        // }
        
        return migrator
    }
}

extension AppDatabase {
    /// Provides a read-only access to the database.
    var reader: any GRDB.DatabaseReader {
        dbWriter
    }
}
// Helper extension for ordering exercises by name, case-insensitively.
extension QueryInterfaceRequest where RowDecoder == Exercise {
    func orderedByName() -> Self {
        order(Exercise.Columns.name.collating(.localizedCaseInsensitiveCompare))
    }
}
