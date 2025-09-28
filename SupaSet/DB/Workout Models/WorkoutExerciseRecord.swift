import GRDB
import Playgrounds
import Foundation


struct WorkoutExerciseWithSets: Decodable, FetchableRecord, Equatable, Hashable{
    var workoutExercise: WorkoutExerciseRecord
    var exerciseSets: [ExerciseSetRecord]
}
struct WorkoutExerciseRecord: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    static let databaseTableName = "workoutExercise"

    var id: Int64?
    var workoutId: Int64
    var exerciseID: String
    var order: Int
    var notes: String?

    // MARK: - Columns Enum
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let workoutId = Column(CodingKeys.workoutId)
        static let exerciseID = Column(CodingKeys.exerciseID)
        static let order = Column(CodingKeys.order)
        static let notes = Column(CodingKeys.notes)
    }

    static let workout = belongsTo(WorkoutRecord.self)
    static let exerciseSets = hasMany(ExerciseSetRecord.self)
    var workout: QueryInterfaceRequest<WorkoutRecord> {
        request(for: WorkoutExerciseRecord.workout)
    }
    var exerciseSets: QueryInterfaceRequest<ExerciseSetRecord> {
        request(for: WorkoutExerciseRecord.exerciseSets)
    }
    static let exercise = belongsTo(Exercise.self, key: "exerciseID")
    var exercise: QueryInterfaceRequest<Exercise> {
        request(for: WorkoutExerciseRecord.exercise)
    }
    // Initializer updated
    init(id: Int64? = nil, workoutId: Int64, exerciseID: String, order: Int, notes: String?) {
        self.id = id
        self.workoutId = workoutId
        self.exerciseID = exerciseID
        self.order = order
        self.notes = notes
    }
}
extension WorkoutExerciseRecord: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}

extension WorkoutExerciseRecord {
    init(from templateExercise: TemplateExercise, workoutId: Int64) {
        self.id = nil
        self.workoutId = workoutId
        self.exerciseID = templateExercise.exerciseID
        self.order = templateExercise.order
        self.notes = templateExercise.notes
    }
}
#Playground {
    
}
