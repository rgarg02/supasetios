//
//  struct.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/2/25.
//


import GRDBQuery
import GRDB
import Foundation

struct TemplateRequest: ValueObservationQueryable {

    static var defaultValue: [WorkoutTemplate] { [] }

    func fetch(_ db: Database) throws -> [WorkoutTemplate] {
        try WorkoutTemplate
            .order(\.creationDate)
            .fetchAll(db)
    }
}

struct TemplateExerciseRequest: ValueObservationQueryable {
    var templateId: Int64?
    static var defaultValue: [ExerciseNameWithCount] { [] }

    func fetch(_ db: Database) throws -> [ExerciseNameWithCount] {
        var output: [ExerciseNameWithCount] = []
        let exercises = try TemplateExercise
            .filter({$0.templateId == templateId})
            .order(\.order)
            .fetchAll(db)
        for exercise in exercises {
            let exerciseName = try Exercise.filter({$0.id == exercise.exerciseID}).fetchOne(db)?.name ?? ""
            output.append(.init(name: exerciseName, count: try TemplateExerciseSet.filter({$0.templateExerciseId == exercise.id}).fetchCount(db)))
        }
        return output
    }
}

struct TemplateExercisesWithSetsRequest: ValueObservationQueryable {
    var templateId: Int64?
    static var defaultValue: [TemplateExerciseWithSets] {[]}
    
    func fetch(_ db: Database) throws -> [TemplateExerciseWithSets] {
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
struct ExerciseNameWithCount: Identifiable {
    var id = UUID()
    let name: String
    let count: Int
}
