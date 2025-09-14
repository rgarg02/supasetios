//
//  WorkoutPageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import SwiftUI
import GRDBQuery
import GRDB
struct WorkoutPageView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State private var isEditingWorkout = false
    @Query(OngoingWorkoutQuery())
    private var ongoingWorkout: WorkoutRecord?
    var body: some View {
        ScrollView{
            VStack {
                TemplateCarasouleView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        do {
                            if ongoingWorkout == nil {
                                try await appDatabase.startWorkout(name: "New Workout", notes: "")
                                isEditingWorkout = true
                            } else {
                                isEditingWorkout = true
                            }
                        } catch {
                            // Handle potential errors during workout creation/action
                            print("Error during workout action: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Label(ongoingWorkout == nil ? "Start Workout" : "Edit Workout", systemImage: ongoingWorkout == nil ? "plus" : "pencil")
                }
            }
        }
    }
}
private struct OngoingWorkoutQuery: ValueObservationQueryable {
    static var defaultValue: WorkoutRecord? { nil }
    
    func fetch(_ db: Database) throws -> WorkoutRecord? {
        try WorkoutRecord.filter{$0.endDate == nil}.fetchOne(db)
    }
}
private struct WorkoutTemplatesQuery: ValueObservationQueryable {
    static var defaultValue: [WorkoutTemplate] { [] }
    
    func fetch(_ db: Database) throws -> [WorkoutTemplate] {
        try WorkoutTemplate
            .fetchAll(db)
    }
}
