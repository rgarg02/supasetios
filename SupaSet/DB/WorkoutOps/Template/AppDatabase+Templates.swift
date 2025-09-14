//
//  AppDatabase+Templates.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/2/25.
//

import GRDB

extension AppDatabase {
    func saveTemplate(_ template: WorkoutTemplate) async throws {
        return try await dbWriter.write { db in
            var template = template
            try template.save(db)
        }
    }
    
    func savedTemplate(_ template: WorkoutTemplate) async throws -> WorkoutTemplate {
        return try await dbWriter.write { db in
            var template = try template.saved(db)
            try template.touch(db)
            return template
        }
    }
}
