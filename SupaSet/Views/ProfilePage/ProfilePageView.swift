//
//  ProfilePageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//
import SwiftUI
import GRDBQuery
import GRDB
struct WorkoutTest: ValueObservationQueryable {
    static var defaultValue: [WorkoutRecord] { [] }
    func fetch(_ db: Database) throws -> [WorkoutRecord] {
        try WorkoutRecord.fetchAll(db)
    }
}
struct WorkoutExerciseTest: ValueObservationQueryable {
    static var defaultValue: [WorkoutExerciseRecord] { [] }
    func fetch(_ db: Database) throws -> [WorkoutExerciseRecord] {
        try WorkoutExerciseRecord.fetchAll(db)
    }
}
struct WorkoutExerciseSetsTest: ValueObservationQueryable {
    static var defaultValue: [ExerciseSetRecord] { [] }
    func fetch(_ db: Database) throws -> [ExerciseSetRecord] {
        try ExerciseSetRecord.fetchAll(db)
    }
}
struct ProfilePageView: View {
    @State private var showSettings = false
    @Environment(\.appDatabase) private var appDatabase
    @Query(WorkoutTest()) private var workouts
    @Query(WorkoutExerciseTest()) private var exercises
    @Query(WorkoutExerciseSetsTest()) private var sets
    var body: some View {
        ScrollView {
            ForEach(workouts, id: \.self){workout in
                Text(workout.name)
            }
            ForEach(exercises, id: \.self){exercise in
                Text(exercise.exerciseID)
            }
            ForEach(sets, id: \.self){set in
                Text(set.order.description)
            }
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gear") {
                    showSettings = true
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsPage(appDatabase: appDatabase)
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePageView()
            .navigationTitle("Profile")
    }
}
