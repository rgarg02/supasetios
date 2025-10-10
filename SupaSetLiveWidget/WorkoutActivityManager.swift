//
//  WorkoutActivityManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/6/25.
//


import Foundation
import ActivityKit
import GRDB

@Observable
@MainActor
class WorkoutActivityManager {
    static let shared = WorkoutActivityManager()
    var currentActivity: Activity<WorkoutAttributes>? = nil
    var currentExerciseSet: ExerciseSetRecord? = nil
    var appDatabase: AppDatabase
    init(currentActivity: Activity<WorkoutAttributes>? = nil) {
        self.currentActivity = currentActivity
        self.appDatabase = .shared
        endLiveActivity()
    }
    func setDatabase(_ appDatabase: AppDatabase) {
        self.appDatabase = appDatabase
        observeExercises()
    }
    func completeSet() {
        if let currentExerciseSet {
            do {
                try appDatabase.dbWriter.write { db in
                    var exerciseSet = currentExerciseSet
                    exerciseSet.isDone = true
                    try exerciseSet.save(db)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    func increaseWeight() {
        if let currentExerciseSet {
            do {
                try appDatabase.dbWriter.write { db in
                    var exerciseSet = currentExerciseSet
                    exerciseSet.weight += 5
                    try exerciseSet.save(db)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    func decreaseWeight() {
        if let currentExerciseSet {
            do {
                try appDatabase.dbWriter.write { db in
                    var exerciseSet = currentExerciseSet
                    exerciseSet.weight = max(0, exerciseSet.weight - 5)
                    try exerciseSet.save(db)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    func increaseReps() {
        if let currentExerciseSet {
            do {
                try appDatabase.dbWriter.write { db in
                    var exerciseSet = currentExerciseSet
                    exerciseSet.reps += 1
                    try exerciseSet.save(db)
                }
            }catch {
                print(error.localizedDescription)
            }
        }
        
    }
    func decreaseReps() {
        if let currentExerciseSet {
            do {
                try appDatabase.dbWriter.write { db in
                    var exerciseSet = currentExerciseSet
                    exerciseSet.reps = max(0, exerciseSet.reps - 1)
                    try exerciseSet.save(db)
                }
            }catch {
                print(error.localizedDescription)
            }
            
        }
    }
    @ObservationIgnored private var cancellable: AnyDatabaseCancellable?
    private func observeExercises() {
        // We observe all players, sorted according to `ordering`.
        let observation = ValueObservation.tracking { db -> (String?, WorkoutRecord?,WorkoutExerciseRecord?,ExerciseSetRecord?, Int?) in
            let workout = try WorkoutRecord.filter({$0.endDate == nil})
                .fetchOne(db)
            if let workout {
                let workoutExercises = try WorkoutExerciseRecord
                    .filter({$0.workoutId == workout.id!})
                    .order(\.order)
                    .fetchAll(db)
                for workoutExercise in workoutExercises {
                    let totalSets = try workoutExercise.exerciseSets.fetchCount(db)
                    if let unfinishedSet = try ExerciseSetRecord
                        .filter({$0.workoutExerciseId == workoutExercise.id!})
                        .filter({$0.isDone == false})
                        .order(\.order)
                        .fetchOne(db) {
                        let exerciseName = try Exercise.filter({$0.id == workoutExercise.exerciseID}).fetchOne(db)?.name
                        return (exerciseName,workout, workoutExercise,unfinishedSet, totalSets)
                    }
                }
            }
            return (nil, nil, nil, nil, nil)
        }
        
        // Start observing the database.
        // Previous observation, if any, is cancelled.
        cancellable = observation.start(in: appDatabase.reader) { error in
            // Handle error
        } onChange: { [unowned self] (exerciseName, workout, exercise,exerciseSet, totalSets) in
            if let exerciseName, let workout, let exercise, let exerciseSet, let totalSets {
                currentExerciseSet = exerciseSet
                updateLiveActivity(startDate: workout.creationDate ?? .now, workoutName: workout.name, exerciseName: exerciseName, exerciseNumber: exercise.order + 1, totalSets: totalSets, currentSetNumber: exerciseSet.order, setType: exerciseSet.setType, weight: exerciseSet.weight, reps: exerciseSet.reps)
            }else {
                endLiveActivity()
            }
        }
    }
    func startLiveActivity(startDate: Date, workoutName: String, exerciseName: String,exerciseNumber:Int, totalSets: Int, currentSetNumber: Int, setType: SetType, weight: Double, reps: Int) {
        let attributes = WorkoutAttributes(startTime: startDate)
        
        let initialState = WorkoutAttributes.ContentState(workoutName: workoutName, exerciseName: exerciseName, exerciseNumber: exerciseNumber, totalSets: totalSets, currentSetNumber: currentSetNumber, setType: setType, weight: weight, reps: reps, setCompleted: false)
        
        do {
            currentActivity = try Activity.request(attributes: attributes, content: ActivityContent(state: initialState, staleDate: nil))
        } catch {
            print("Error starting live activity: \(error)")
        }
    }
    
    func updateLiveActivity(startDate: Date, workoutName: String, exerciseName: String,exerciseNumber:Int, totalSets: Int, currentSetNumber: Int, setType: SetType, weight: Double, reps: Int) {
        let updatedState = WorkoutAttributes.ContentState(workoutName: workoutName, exerciseName: exerciseName, exerciseNumber: exerciseNumber, totalSets: totalSets, currentSetNumber: currentSetNumber, setType: setType, weight: weight, reps: reps, setCompleted: false)
        let content = ActivityContent(state: updatedState, staleDate: nil)
        if let currentActivity {
            Task {
                await currentActivity.update(content)
            }
        }else {
            startLiveActivity(startDate: startDate, workoutName: workoutName, exerciseName: exerciseName, exerciseNumber: exerciseNumber, totalSets: totalSets, currentSetNumber: currentSetNumber, setType: setType, weight: weight, reps: reps)
        }
    }
    
    func endLiveActivity() {
        Task {
            for activity in Activity<WorkoutAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
                currentActivity = nil
            }
        }
    }
}
