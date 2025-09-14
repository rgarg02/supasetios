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
    var weight: Double?
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
         weight: Double? = nil,
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
