//
//  RepType.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/31/25.
//


//
// TemplateExerciseSet.swift
// SupaSet
//
// Created by Rishi Garg on 8/31/25.
//

import Foundation
import GRDB
import FoundationModels

extension TemplateExerciseSet.RepType: DatabaseValueConvertible {}

struct TemplateExerciseSet: Codable, Hashable, Identifiable, FetchableRecord {
    enum RepType: Codable, Hashable {
        case reps(Int?)
        case range(Int?, Int?)
        var description: String {
            switch self {
            case .reps(_):
                return "Reps"
            case .range(_, _ ):
                return "Range"
            }
        }
    }
    var id: Int64?
    var templateExerciseId: Int64?
    var repType: RepType
    var weight: Double
    private(set) var type: String
    var rpe: Double?
    var notes: String?
    var order: Int

    var setType: SetType {
        get { SetType(rawValue: type)! }
        set { type = newValue.rawValue }
    }
    
    static let databaseTableName = "templateExerciseSet"

    // Define database association
    static let templateExercise = belongsTo(TemplateExercise.self)
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let templateExerciseId = Column(CodingKeys.templateExerciseId)
        static let repType = Column(CodingKeys.repType)
        static let weight = Column(CodingKeys.weight)
        static let type = Column(CodingKeys.type)
        static let notes = Column(CodingKeys.notes)
        static let order = Column(CodingKeys.order)
    }
    init(id: Int64? = nil,
         templateExerciseId: Int64? = nil,
         repType: RepType = .reps(nil),
         weight: Double = 0,
         type: SetType,
         rpe: Double? = nil,
         notes: String? = nil,
         order: Int
    )
    {
        self.id = id
        self.templateExerciseId = templateExerciseId
        self.repType = repType
        self.weight = weight
        self.type = type.rawValue
        self.rpe = rpe
        self.notes = notes
        self.order = order
    }
}
extension TemplateExerciseSet: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}
extension TemplateExerciseSet {
    init(_ exerciseSet: ExerciseSetRecord, id: Int64? = nil, templateExerciseId: Int64? = nil) {
        self.id = id
        self.templateExerciseId = templateExerciseId
        self.repType = .reps(exerciseSet.reps)
        self.weight = exerciseSet.weight
        self.type = exerciseSet.setType.rawValue
        self.rpe = exerciseSet.rpe
        self.notes = exerciseSet.notes
        self.order = exerciseSet.order
    }
}
extension TemplateExerciseSet {
    init(_ templateSet: TemplateExerciseSet?, order: Int) {
        self.id = nil
        self.templateExerciseId = templateSet?.templateExerciseId
        self.repType = templateSet?.repType ?? .reps(nil)
        self.weight = templateSet?.weight ?? .zero
        self.notes = nil
        self.order = order
        self.type = templateSet?.type ?? SetType.working.rawValue
        self.rpe = templateSet?.rpe ?? nil
    }
}
