//
//  AppDatabase+TemplateExercise.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/2/25.
//


import GRDB

extension AppDatabase {
    
    func savedTemplateExercise(_ templateExercise: TemplateExercise) async throws -> TemplateExercise {
        return try await dbWriter.write { db in
            try templateExercise.saved(db)
        }
    }
    
    func fetchTemplateExercisesWithSets(templateId: Int64?) async throws -> [TemplateExerciseWithSets] {
        return try await reader.read { db in
            var output: [TemplateExerciseWithSets] = []
            let exercises = try TemplateExercise
                .filter({$0.templateId == templateId})
                .order(\.order)
                .fetchAll(db)
            for exercise in exercises {
                let sets = try TemplateExerciseSet
                    .filter({$0.templateExerciseId == exercise.id})
                    .order(\.order)
                    .fetchAll(db)
                output.append(.init(templateExercise: exercise, templateSets: sets))
            }
            return output
        }
    }
}
