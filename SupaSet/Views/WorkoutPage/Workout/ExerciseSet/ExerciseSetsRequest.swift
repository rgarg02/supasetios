//
//  ExerciseSetsRequest.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/26/25.
//


// MARK: - Request
import GRDBQuery
import GRDB
struct ExerciseSetsRequest: ValueObservationQueryable {
    var workoutExerciseId: Int64
    
    static var defaultValue: [CurrentAndPreviousSet] { [] }
    
    func fetch(_ db: Database) throws -> [CurrentAndPreviousSet] {
        let currentSets = try ExerciseSetRecord
            .filter { $0.workoutExerciseId == workoutExerciseId }
            .order(\.order)
            .fetchAll(db)
        
        var currentAndPreviousSets: [CurrentAndPreviousSet] = []
        
        let currentWorkoutExercise = try WorkoutExerciseRecord
            .filter{$0.id == workoutExerciseId}
            .fetchOne(db)
        guard let currentWorkoutExercise else {
            return []
        }
        // For each current set, find the matching previous set
        for currentSet in currentSets {
            let sql = """
                    SELECT es.*
                    FROM exerciseSet es
                    JOIN workoutExercise we ON we.id = es.workoutExerciseId
                    JOIN workout w ON w.id = we.workoutId
                    WHERE we.exerciseID = ?
                      AND es."order" = ?
                      AND w.endDate IS NOT NULL
                      AND es.isDone = 1
                    ORDER BY w.endDate DESC
                    LIMIT 1
                """
            
            // Execute the query with arguments to prevent SQL injection
            let previousSet = try ExerciseSetRecord.fetchOne(db, sql: sql, arguments: [
                currentWorkoutExercise.exerciseID,
                currentSet.order
            ])
            
            let workingSetOrder = try ExerciseSetRecord
                .filter({$0.workoutExerciseId == workoutExerciseId})
                .filter({$0.type == "working"})
                .filter{$0.order < currentSet.order}
                .fetchCount(db)
            print(workingSetOrder)
            currentAndPreviousSets.append(CurrentAndPreviousSet(current: currentSet, previous: previousSet, workingSetOrder: workingSetOrder))
        }
        return currentAndPreviousSets
    }
}
