//
//  AppDatabse+TemplateSet.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/2/25.
//

import GRDB

extension AppDatabase {
    func savedTemplateSet(_ templateSet: TemplateExerciseSet) async throws -> TemplateExerciseSet {
        return try await dbWriter.write { db in
            try templateSet.saved(db)
        }
    }
}
