//
//  WorkoutTemplate.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/31/25.
//


//
// WorkoutTemplate.swift
// SupaSet
//
// Created by Rishi Garg on 8/31/25.
//

import Foundation
import GRDB

struct WorkoutTemplate: Codable, Hashable, Identifiable, FetchableRecord {
    var id: Int64?
    var name: String
    var creationDate: Date?
    var modificationDate: Date?
    var notes: String

    static let databaseTableName = "workoutTemplate"

    // Define database associations
    static let templateExercises = hasMany(TemplateExercise.self)

    var templateExercises: QueryInterfaceRequest<TemplateExercise> {
        request(for: Self.templateExercises)
    }
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let creationDate = Column(CodingKeys.creationDate)
        static let modificationDate = Column(CodingKeys.modificationDate)
        static let notes = Column(CodingKeys.notes)
    }
}
extension WorkoutTemplate: MutablePersistableRecord, TimestampedRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}
