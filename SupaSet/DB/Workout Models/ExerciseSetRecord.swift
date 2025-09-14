import GRDB
import SwiftUI

struct ExerciseSetRecord: Codable, FetchableRecord, PersistableRecord, Equatable {
    static let databaseTableName = "exerciseSet"

    var id: Int64?                   // Changed
    var workoutExerciseId: Int64     // Changed (Foreign Key to WorkoutExerciseRecord.id)
    var reps: Int
    var weight: Double
    private(set) var type: String    // Stores SetType raw value
    var rpe: Double?
    var notes: String?
    var order: Int
    var isDone: Bool

    // MARK: - Columns Enum
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let workoutExerciseId = Column(CodingKeys.workoutExerciseId)
        static let reps = Column(CodingKeys.reps)
        static let weight = Column(CodingKeys.weight)
        static let type = Column(CodingKeys.type)
        static let rpe = Column(CodingKeys.rpe)
        static let notes = Column(CodingKeys.notes)
        static let order = Column(CodingKeys.order)
        static let isDone = Column(CodingKeys.isDone)
    }

    static let workoutExercise = belongsTo(WorkoutExerciseRecord.self)
    var workoutExercise: QueryInterfaceRequest<WorkoutExerciseRecord> {
        request(for: ExerciseSetRecord.workoutExercise)
    }

    // Initialize with a SetType, storing its rawValue internally
    init(id: Int64? = nil,
         workoutExerciseId: Int64,
         reps: Int,
         weight: Double,
         type: SetType,
         rpe: Double? = nil,
         notes: String? = nil,
         order: Int,
         isDone: Bool)
    {
        self.id = id
        self.workoutExerciseId = workoutExerciseId
        self.reps = reps
        self.weight = weight
        self.type = type.rawValue
        self.rpe = rpe
        self.notes = notes
        self.order = order
        self.isDone = isDone
    }

    // Expose a non-optional SetType for getting & setting
    var setType: SetType {
        get {
            // Force-unwrap is safe if the database never contains invalid values.
            SetType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
}

extension ExerciseSetRecord: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}

extension ExerciseSetRecord {
    init(from templateSet: TemplateExerciseSet, workoutExerciseId: Int64) {
        self.id = nil
        self.workoutExerciseId = workoutExerciseId
        var reps: Int
        switch templateSet.repType {
        case .reps(let newReps):
            reps = newReps ?? 0
        case .range(let lowerBound, let upperBound):
            reps = lowerBound ?? 0
        }
        self.reps = reps
        self.weight = templateSet.weight ?? 0
        self.type = templateSet.type
        self.rpe = templateSet.rpe
        self.notes = templateSet.notes
        self.order = templateSet.order
        self.isDone = false
    }
}
struct CurrentAndPreviousSet: Equatable {
    let current: ExerciseSetRecord
    let previous: ExerciseSetRecord?
    let workingSetOrder: Int
}
