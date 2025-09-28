//
//  HistoryPageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/4/25.
//

import SwiftUI
import GRDB
import GRDBQuery
struct HistoryPageView: View {
    @Query(CompletedWorkoutsRequest())
    private var workouts: [WorkoutRecord]
    @Namespace var namespace
    var body: some View {
        ScrollView {
            if workouts.isEmpty {
                ContentUnavailableView("No workouts yet...", image: "figure" , description: Text("Start a workout to see it here."))
            }
            VStack {
                ForEach(workouts, id: \.id) {workout in
                    NavigationLink {
//                        WorkoutEditView(workout: workout)
//                            .navigationTransition(.zoom(sourceID: workout.id, in: namespace))
                        
                    } label: {
                        WorkoutRowView(workout: workout)
                            .padding(.horizontal)
                            .matchedTransitionSource(id: workout.id, in: namespace)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("History")
    }
}
struct WorkoutRowView: View {
    let workout: WorkoutRecord
    var body: some View {
        VStack {
            HStack {
                Text(workout.name)
                    .frame(alignment: .leading)
                Text(workout.creationDate?.formatted() ?? "")
                    .frame(alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .cornerRadius(12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill (LinearGradient(colors: [.bgLight, .bg], startPoint: .top, endPoint: .bottom))
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient(colors: [.highlight, .border], startPoint: .top, endPoint: .bottom), style: .init(lineWidth: 1))
            }
        )
    }
}
struct CompletedWorkoutsRequest: ValueObservationQueryable {
    static var defaultValue: [WorkoutRecord] { [] }

    func fetch(_ db: Database) throws -> [WorkoutRecord] {
        return try WorkoutRecord
            .order(\.endDate.desc)
            .filter({$0.endDate != nil})
            .fetchAll(db)
    }
}

#Preview {
    HistoryPageView()
        .appDatabase(.completedWorkouts())
}
