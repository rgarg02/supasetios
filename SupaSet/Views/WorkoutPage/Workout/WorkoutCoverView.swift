//
//  WorkoutCoverView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/20/25.
//

import SwiftUI
import GRDB
import SwiftfulRouting
struct WorkoutCoverView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) private var dismiss
    let workout: WorkoutRecord
    @State private var offset: CGFloat = .zero
    var body: some View {
            WorkoutEditView(workout: workout)
                
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
