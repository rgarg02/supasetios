//
//  WorkoutCoverView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/20/25.
//

import SwiftUI
import GRDBQuery
struct WorkoutCoverView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) private var dismiss
    let workout: WorkoutRecord
    @State private var offset: CGFloat = .zero
    
    @Query<WorkoutExercisesWithSetsRequest>
    private var workoutExercisesWithSets: [WorkoutExerciseWithSets]
    
    init(workout: WorkoutRecord){
        self.workout = workout
        self._workoutExercisesWithSets = Query(WorkoutExercisesWithSetsRequest(workoutId: workout.id))
    }
    var body: some View {
            WorkoutEditView(workout: workout, workoutExercisesWithSets: workoutExercisesWithSets, isNew: true)
    }
}

#Preview {
    let sampleWorkout = WorkoutRecord(
        id: 1,
        name: "Preview Workout",
        creationDate: Date(),
        modificationDate: Date(),
        endDate: nil,
        notes: "Preview notes"
    )
    return WorkoutCoverView(workout: sampleWorkout)
        .appDatabase(.withBodyweightExercises())
}
