import GRDB
import Foundation

struct WorkoutRecord: Codable, FetchableRecord, Equatable, Hashable {
    static let databaseTableName = "workout"

    var id: Int64? // Changed to auto-incrementing Int64
    var name: String
    var creationDate: Date?
    var modificationDate: Date?
    var endDate: Date?
    var notes: String
    var duration: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(creationDate ?? .now)
    }
    var isFinished: Bool {
        endDate != nil
    }
    // MARK: - Columns Enum
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let creationDate = Column(CodingKeys.creationDate)
        static let modificationDate = Column(CodingKeys.modificationDate)
        static let endDate = Column(CodingKeys.endDate)
        static let notes = Column(CodingKeys.notes)
    }
    
    static let exercises = hasMany(WorkoutExerciseRecord.self)

    var exercises: QueryInterfaceRequest<WorkoutExerciseRecord> {
        request(for: WorkoutRecord.exercises)
    }
    static func == (lhs: WorkoutRecord, rhs: WorkoutRecord) -> Bool {
        // Compare all properties EXCEPT modificationDate
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.creationDate == rhs.creationDate &&
        lhs.endDate == rhs.endDate &&
        lhs.notes == rhs.notes
    }
}
extension WorkoutRecord: MutablePersistableRecord, TimestampedRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}

