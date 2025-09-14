//
//  AppDatabase+ExerciseWrites.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import Foundation
import GRDB

// MARK: - Database Access: Writes
// The write methods execute invariant-preserving database transactions.

extension AppDatabase {
    // MARK: - Exercise Management
    
    /// Saves (inserts or updates) an exercise. When the method returns, the
    /// exercise is present in the database.
    func saveExercise(_ exercise: inout Exercise) throws {
        try dbWriter.write { db in
            try exercise.save(db)
        }
    }
    
    /// Saves a complete exercise with all its related data
    func saveCompleteExercise(
        _ exercise: inout Exercise,
        primaryMuscles: [MuscleGroup],
        secondaryMuscles: [MuscleGroup],
        instructions: [String],
        imageUrls: [String]
    ) throws {
        try dbWriter.write { db in
            // Save the exercise
            try exercise.save(db)
            
            // Clear existing related data
            try ExercisePrimaryMuscle.filter(ExercisePrimaryMuscle.Columns.exerciseId == exercise.id).deleteAll(db)
            try ExerciseSecondaryMuscle.filter(ExerciseSecondaryMuscle.Columns.exerciseId == exercise.id).deleteAll(db)
            try ExerciseInstruction.filter(ExerciseInstruction.Columns.exerciseId == exercise.id).deleteAll(db)
            try ExerciseImage.filter(ExerciseImage.Columns.exerciseId == exercise.id).deleteAll(db)
            
            // Insert primary muscles
            for muscle in primaryMuscles {
                var primaryMuscle = ExercisePrimaryMuscle(exerciseId: exercise.id, muscleGroup: muscle)
                try primaryMuscle.save(db)
            }
            
            // Insert secondary muscles
            for muscle in secondaryMuscles {
                var secondaryMuscle = ExerciseSecondaryMuscle(exerciseId: exercise.id, muscleGroup: muscle)
                try secondaryMuscle.save(db)
            }
            
            // Insert instructions
            for (index, instruction) in instructions.enumerated() {
                var exerciseInstruction = ExerciseInstruction(
                    id: nil,
                    exerciseId: exercise.id,
                    stepNumber: index + 1,
                    instruction: instruction
                )
                try exerciseInstruction.save(db)
            }
            
            // Insert images
            for (index, imageUrl) in imageUrls.enumerated() {
                var exerciseImage = ExerciseImage(
                    id: nil,
                    exerciseId: exercise.id,
                    imageUrl: imageUrl,
                    orderIndex: index
                )
                try exerciseImage.save(db)
            }
        }
    }
    
    /// Delete the specified exercises
    func deleteExercises(ids: [String]) throws {
        try dbWriter.write { db in
            _ = try Exercise.deleteAll(db, keys: ids)
        }
    }
    
    /// Delete all exercises
    func deleteAllExercises() throws {
        try dbWriter.write { db in
            _ = try Exercise.deleteAll(db)
        }
    }
    
    // MARK: - Exercise Instructions Management
    
    /// Save exercise instructions
    func saveExerciseInstructions(_ instructions: [ExerciseInstruction]) throws {
        try dbWriter.write { db in
            for var instruction in instructions {
                try instruction.save(db)
            }
        }
    }
    
    /// Update exercise instruction
    func updateExerciseInstruction(_ instruction: inout ExerciseInstruction) throws {
        try dbWriter.write { db in
            try instruction.save(db)
        }
    }
    
    // MARK: - Exercise Images Management
    
    /// Save exercise images
    func saveExerciseImages(_ images: [ExerciseImage]) throws {
        try dbWriter.write { db in
            for var image in images {
                try image.save(db)
            }
        }
    }
    
    /// Update exercise image
    func updateExerciseImage(_ image: inout ExerciseImage) throws {
        try dbWriter.write { db in
            try image.save(db)
        }
    }
}
