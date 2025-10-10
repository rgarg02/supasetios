//
//  AppDatabase+ExerciseReads.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import Foundation
import GRDB

// MARK: - Database Access: Reads

extension AppDatabase {
    
    // MARK: - Convenience Read Methods
    
    private func filteredExerciseRequest(
        searchText: String = ""
    ) -> QueryInterfaceRequest<Exercise> {
        
        var request = Exercise.all()
        
        if !searchText.isEmpty {
            let pattern = FTS5Pattern(matchingAllPrefixesIn: searchText)
            
            // 1. Start the subquery from the 'ExerciseFTS' model, not 'Exercise'.
            let matchingIdsRequest = ExerciseFTS
                .matching(pattern)
                // 2. Select the 'id' column, which is the String primary key
                // synchronized from the 'exercises' table.
                .select(Column("id"), as: String.self)
                
            // 3. Filter the main 'Exercise' request where its 'id' column
            // is present in the results from the FTS subquery.
            request = request.filter(matchingIdsRequest.contains(Exercise.Columns.id))
        }
        
        return request
    }
    func fetchExerciseName(for exerciseId: String) async throws -> String? {
        return try await reader.read { db in
            try Exercise
                .filter{$0.id == exerciseId}
                .fetchOne(db)?
                .name
        }
    }
    func fetchClosestExerciseNames(to name: String) async throws -> [String] {
        let request = filteredExerciseRequest(searchText: name)
        let exercises = try await reader.read { db in
            try request
                .order(Column("name").asc) // Consistent ordering is crucial for pagination
                .limit(3)
                .fetchAll(db)
        }
        return exercises.map({$0.name})
    }
    func fetchAllExercises(searchText: String = "") async throws -> [ExerciseRowDetail] {
        let request = filteredExerciseRequest(searchText: searchText)
        return try await reader.read { db in
            let exercises =
            try request
                .order(Column("name").asc)
                .fetchAll(db)
            return try exercises.map { exercise in
                let primaryMuscles = try ExercisePrimaryMuscle
                    .filter(ExercisePrimaryMuscle.Columns.exerciseId == exercise.id)
                    .fetchAll(db)
                    .map(\.muscleGroup)
                
                let secondaryMuscles = try ExerciseSecondaryMuscle
                    .filter(ExerciseSecondaryMuscle.Columns.exerciseId == exercise.id)
                    .fetchAll(db)
                    .map(\.muscleGroup)
                return ExerciseRowDetail(id: exercise.id, name: exercise.name, force: exercise.force, level: exercise.level, equipment: exercise.equipment, primaryMuscles: primaryMuscles, category: exercise.category, frequency: exercise.frequency)
            }
        }
    }
    /// Fetch all exercises with their complete data, with pagination.
    /// - Parameters:
    ///   - limit: The maximum number of exercises to fetch.
    ///   - offset: The number of exercises to skip from the beginning.
    func fetchCompleteExercises(limit: Int, offset: Int, searchText: String = "") async throws -> [ExerciseJSON] {
        let request = filteredExerciseRequest(searchText: searchText)
        let exercises = try await reader.read { db in
            try request
                .order(Column("name").asc) // Consistent ordering is crucial for pagination
                .limit(limit, offset: offset)
                .fetchAll(db)
        }
        return try await reader.read {db in
            
            //        try await reader.read { db in
            //            let exercises = try Exercise.all()
            //                .limit(limit, offset: offset) // Apply limit and offset for pagination
            //                .fetchAll(db)
            //
            return try exercises.map { exercise in
                let primaryMuscles = try ExercisePrimaryMuscle
                    .filter(ExercisePrimaryMuscle.Columns.exerciseId == exercise.id)
                    .fetchAll(db)
                    .map(\.muscleGroup)
                
                let secondaryMuscles = try ExerciseSecondaryMuscle
                    .filter(ExerciseSecondaryMuscle.Columns.exerciseId == exercise.id)
                    .fetchAll(db)
                    .map(\.muscleGroup)
                
                let instructions = try ExerciseInstruction
                    .filter(ExerciseInstruction.Columns.exerciseId == exercise.id)
                    .order(ExerciseInstruction.Columns.stepNumber)
                    .fetchAll(db)
                    .map(\.instruction) // Map to array of strings
                
                let images = try ExerciseImage
                    .filter(ExerciseImage.Columns.exerciseId == exercise.id)
                    .order(ExerciseImage.Columns.orderIndex)
                    .fetchAll(db)
                    .map(\.imageUrl) // Map to array of strings
                
                return ExerciseJSON(
                    id: exercise.id,
                    name: exercise.name,
                    force: exercise.force,
                    level: exercise.level,
                    mechanic: exercise.mechanic,
                    equipment: exercise.equipment,
                    primaryMuscles: primaryMuscles,
                    secondaryMuscles: secondaryMuscles,
                    instructions: instructions,
                    category: exercise.category,
                    images: images,
                    frequency: exercise.frequency
                )
            }
        }
//        }
    }
    
    /// Search exercises by name
    func searchExercises(by name: String) throws -> [Exercise] {
        try reader.read { db in
            try Exercise
                .filter(Exercise.Columns.name.like("%\(name)%"))
                .order(Exercise.Columns.name)
                .fetchAll(db)
        }
    }
    
    /// Filter exercises by muscle group
    func exercisesForMuscleGroup(_ muscleGroup: MuscleGroup) throws -> [Exercise] {
        try reader.read { db in
            let exerciseIds = try ExercisePrimaryMuscle
                .filter(ExercisePrimaryMuscle.Columns.muscleGroup == muscleGroup)
                .fetchAll(db)
                .map(\.exerciseId)
            
            return try Exercise
                .filter(keys: exerciseIds)
                .order(Exercise.Columns.name)
                .fetchAll(db)
        }
    }
}
