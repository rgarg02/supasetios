//
//  AppDatabase+BulkOperations.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import Foundation
import GRDB

// MARK: - Bulk Operations

extension AppDatabase {
    /// Import exercises from a data source (useful for initial data population)
    func importExercises(_ exerciseData: [(exercise: Exercise, primaryMuscles: [MuscleGroup], secondaryMuscles: [MuscleGroup], instructions: [String], imageUrls: [String])]) throws {
        try dbWriter.write { db in
            for var data in exerciseData {
                // Insert exercise
                try data.exercise.save(db)
                
                // Insert primary muscles
                for muscle in data.primaryMuscles {
                    var primaryMuscle = ExercisePrimaryMuscle(exerciseId: data.exercise.id, muscleGroup: muscle)
                    try primaryMuscle.save(db)
                }
                
                // Insert secondary muscles
                for muscle in data.secondaryMuscles {
                    var secondaryMuscle = ExerciseSecondaryMuscle(exerciseId: data.exercise.id, muscleGroup: muscle)
                    try secondaryMuscle.save(db)
                }
                
                // Insert instructions
                for (index, instruction) in data.instructions.enumerated() {
                    var exerciseInstruction = ExerciseInstruction(
                        id: nil,
                        exerciseId: data.exercise.id,
                        stepNumber: index + 1,
                        instruction: instruction
                    )
                    try exerciseInstruction.save(db)
                }
                
                // Insert images
                for (index, imageUrl) in data.imageUrls.enumerated() {
                    var exerciseImage = ExerciseImage(
                        id: nil,
                        exerciseId: data.exercise.id,
                        imageUrl: imageUrl,
                        orderIndex: index
                    )
                    try exerciseImage.save(db)
                }
            }
        }
    }
    
    /// Create sample exercises if the database is empty (for demo purposes)
    func createSampleExercisesIfEmpty() throws {
        try dbWriter.write { db in
            if try Exercise.all().isEmpty(db) {
                try createSampleExercises(db)
            }
        }
    }
    
    /// Support for `createSampleExercisesIfEmpty()`
    private func createSampleExercises(_ db: Database) throws {
        let sampleExercises = [
            (
                exercise: Exercise(
                    id: "bench-press",
                    name: "Bench Press",
                    force: .push,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .barbell,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.chest],
                secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
                instructions: [
                    "Lie on the bench with your eyes under the bar",
                    "Grip the bar with hands slightly wider than shoulder width",
                    "Lower the bar to your chest with control",
                    "Press the bar back up to starting position"
                ],
                imageUrls: ["bench-press-1.jpg", "bench-press-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "squat",
                    name: "Squat",
                    force: .push,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .barbell,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.quadriceps],
                secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
                instructions: [
                    "Stand with feet shoulder-width apart",
                    "Lower your body by bending at the hips and knees",
                    "Keep your chest up and knees tracking over toes",
                    "Push through your heels to return to starting position"
                ],
                imageUrls: ["squat-1.jpg", "squat-2.jpg"]
            ),
            (
                exercise: Exercise(
                    id: "pull-up",
                    name: "Pull-up",
                    force: .pull,
                    level: .intermediate,
                    mechanic: .compound,
                    equipment: .bodyOnly,
                    category: .strength,
                    frequency: 1
                ),
                primaryMuscles: [MuscleGroup.lats],
                secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.middleBack],
                instructions: [
                    "Hang from the bar with palms facing away",
                    "Pull your body up until your chin is over the bar",
                    "Lower yourself back down with control",
                    "Keep your core engaged throughout the movement"
                ],
                imageUrls: ["pullup-1.jpg", "pullup-2.jpg"]
            )
        ]
        
        for var exerciseData in sampleExercises {
            // Insert exercise
            try exerciseData.exercise.save(db)
            
            // Insert primary muscles
            for muscle in exerciseData.primaryMuscles {
                var primaryMuscle = ExercisePrimaryMuscle(exerciseId: exerciseData.exercise.id, muscleGroup: muscle)
                try primaryMuscle.save(db)
            }
            
            // Insert secondary muscles
            for muscle in exerciseData.secondaryMuscles {
                var secondaryMuscle = ExerciseSecondaryMuscle(exerciseId: exerciseData.exercise.id, muscleGroup: muscle)
                try secondaryMuscle.save(db)
            }
            
            // Insert instructions
            for (index, instruction) in exerciseData.instructions.enumerated() {
                var exerciseInstruction = ExerciseInstruction(
                    id: nil,
                    exerciseId: exerciseData.exercise.id,
                    stepNumber: index + 1,
                    instruction: instruction
                )
                try exerciseInstruction.save(db)
            }
            
            // Insert images
            for (index, imageUrl) in exerciseData.imageUrls.enumerated() {
                var exerciseImage = ExerciseImage(
                    id: nil,
                    exerciseId: exerciseData.exercise.id,
                    imageUrl: imageUrl,
                    orderIndex: index
                )
                try exerciseImage.save(db)
            }
        }
    }
}
