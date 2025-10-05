//
//  TemplateExercise.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/31/25.
//


//
// TemplateExercise.swift
// SupaSet
//
// Created by Rishi Garg on 8/31/25.
//

import Foundation
import GRDB


struct FullTemplateExercise: Encodable, Hashable {
    var templateExercise: TemplateExercise
    var templateExerciseSets: [TemplateExerciseSet]
}
extension [TemplateExerciseSet] {
    mutating func addSet() {
        let previousSet = self.last
        self.append(.init(previousSet, order: self.count))
    }
}
struct TemplateExercise: Codable, Hashable, Identifiable, FetchableRecord {
    var id: Int64?
    var templateId: Int64?
    var exerciseID: String
    var order: Int
    var notes: String?

    static let databaseTableName = "templateExercise"

    // Define database associations
    static let template = belongsTo(WorkoutTemplate.self)
    static let exercise = belongsTo(Exercise.self)
    static let templateSets = hasMany(TemplateExerciseSet.self)

    var templateSets: QueryInterfaceRequest<TemplateExerciseSet> {
        request(for: Self.templateSets)
    }
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let templateId = Column(CodingKeys.templateId)
        static let exerciseID = Column(CodingKeys.exerciseID)
        static let order = Column(CodingKeys.order)
        static let notes = Column(CodingKeys.notes)
    }
}
extension TemplateExercise: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}
