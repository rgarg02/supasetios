//
//  Protocols.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/29/25.
//

import Foundation

// Defines the properties common to both TemplateExercise and WorkoutExerciseRecord.
protocol ExerciseProtocol: Hashable {
    var exerciseID: String { get set }
    var order: Int { get }
}

// Defines the properties and behavior common to both TemplateExerciseSet and ExerciseSetRecord.
protocol ExerciseSetProtocol: Hashable {
    var order: Int { get }
    var weight: Double { get set }
    var setType: SetType { get set }
    var repType: TemplateExerciseSet.RepType { get set }
    
    // Determines if the set type can be switched to a range.
    // Templates support ranges, but completed workout sets do not.
    var supportsRange: Bool { get }
}

// A wrapper protocol for a parent object that holds an exercise and its sets.
protocol ExerciseWithSetsProtocol {
    // Associated types allow this protocol to work with any type conforming to the other protocols.
    associatedtype Exercise: ExerciseProtocol
    associatedtype ExerciseSet: ExerciseSetProtocol

    var exercise: Exercise { get set }
    var sets: [ExerciseSet] { get set }
    
    // Each wrapper will define its own logic for adding a new set.
    mutating func addNewSet()
}


// MARK: - Exercise Protocol Conformance
// TemplateExercise already has the required properties.
extension TemplateExercise: ExerciseProtocol {}

// WorkoutExerciseRecord also has the required properties.
extension WorkoutExerciseRecord: ExerciseProtocol {}


// MARK: - Exercise Set Protocol Conformance
extension TemplateExerciseSet: ExerciseSetProtocol {
    // Templates support switching to a rep range.
    var supportsRange: Bool { return true }
}

extension ExerciseSetRecord: ExerciseSetProtocol {
    // An actual workout set only has a single rep count, not a range.
    var supportsRange: Bool { return false }
    
    // This computed property adapts the `reps: Int` from ExerciseSetRecord
    // to the `repType: RepType` required by the protocol and view.
    var repType: TemplateExerciseSet.RepType {
        get {
            // Always present the stored reps as a `.reps` type.
            .reps(reps)
        }
        set {
            // When the view tries to set the repType, extract the integer value.
            switch newValue {
            case .reps(let newReps):
                self.reps = newReps ?? 0
            case .range(let lowerBound, _):
                // If the UI tries to set a range, default to using the lower bound.
                self.reps = lowerBound ?? 0
            }
        }
    }
}


// MARK: - ExerciseWithSets Protocol Conformance
extension TemplateExerciseWithSets: ExerciseWithSetsProtocol {
    // Define the associated types for the protocol.
    typealias Exercise = TemplateExercise
    typealias ExerciseSet = TemplateExerciseSet

    // Computed properties to map the struct's properties to the protocol's requirements.
    var exercise: TemplateExercise {
        get { templateExercise }
        set { templateExercise = newValue }
    }
    
    var sets: [TemplateExerciseSet] {
        get { templateSets }
        set { templateSets = newValue }
    }
    
    // The logic for adding a new template set.
    mutating func addNewSet() {
        let newOrder = self.sets.count
        var newSet: TemplateExerciseSet
        
        if let lastSet = self.sets.last {
            // Copy properties from the last set for convenience.
            newSet = TemplateExerciseSet(repType: lastSet.repType, weight: lastSet.weight, type: lastSet.setType, rpe: lastSet.rpe, notes: lastSet.notes, order: newOrder)
        } else {
            // Create a default first set.
            newSet = TemplateExerciseSet(type: .working, order: newOrder)
        }
        self.sets.append(newSet)
    }
}


// The original file for this struct only defined properties. We add protocol conformance.
extension WorkoutExerciseWithSets: ExerciseWithSetsProtocol {
    typealias Exercise = WorkoutExerciseRecord
    typealias ExerciseSet = ExerciseSetRecord

    var exercise: WorkoutExerciseRecord {
        get { workoutExercise }
        set { workoutExercise = newValue }
    }

    var sets: [ExerciseSetRecord] {
        get { exerciseSets }
        set { exerciseSets = newValue }
    }

    mutating func addNewSet() {
        // A workout exercise must be saved (and have an ID) before sets can be added.
        guard let workoutExerciseId = self.exercise.id else {
            print("Error: Cannot add a set to an unsaved workout exercise.")
            return
        }
        
        let newOrder = self.sets.count
        var newSet: ExerciseSetRecord

        if let lastSet = self.sets.last {
            // Copy properties from the previous set.
            newSet = ExerciseSetRecord(workoutExerciseId: workoutExerciseId, reps: lastSet.reps, weight: lastSet.weight, type: lastSet.setType, rpe: lastSet.rpe, notes: lastSet.notes, order: newOrder, isDone: false)
        } else {
            // Create a default first set for the workout.
            newSet = ExerciseSetRecord(workoutExerciseId: workoutExerciseId, reps: 0, weight: 0, type: .working, order: newOrder, isDone: false)
        }
        self.sets.append(newSet)
    }
}
