//
//  ContentView.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import SwiftUI
import GRDBQuery
import GRDB
struct ContentView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Query(OngoingWorkoutQuery())
    private var ongoingWorkout: WorkoutRecord?
    @State private var expandWorkout: Bool = false
    @Namespace private var animation
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                NativeTabView(appDatabase: appDatabase)
                    .tabBarMinimizeBehavior(.onScrollDown)
                    .tabViewBottomAccessory {
                        if let ongoingWorkout {
                            MiniWorkoutView(ongoingWorkout)
                                .matchedTransitionSource(id: "MINIWORKOUT", in: animation)
                                .contentShape(.rect)
                                .onTapGesture {
                                    expandWorkout.toggle()
                                }
                        }
                        
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if ongoingWorkout == nil {
                            startWorkoutButton()
                                .buttonStyle(.glass)
                                .transition(.scale.combined(with: .blurReplace))
                        }
                    }
                    .animation(.default, value: ongoingWorkout)
            } else {
                NativeTabView(60, appDatabase: appDatabase)
                    .overlay(alignment: .bottomTrailing) {
                        if let ongoingWorkout{
                            MiniWorkoutView(ongoingWorkout)
                                .padding(.vertical, 8)
                                .background(content: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                                            .fill(.gray.opacity(0.3))
                                        
                                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                                            .fill(.background)
                                            .padding(1.2)
                                    }
                                    .compositingGroup()
                                })
                                .matchedTransitionSource(id: "MINIWORKOUT", in: animation)
                                .contentShape(.rect)
                                .onTapGesture {
                                    expandWorkout.toggle()
                                }
                                .offset(y: -52)
                                .padding(.horizontal, 15)
                        }else {
                            startWorkoutButton()
                                .buttonStyle(.borderedProminent)
                                .transition(.scale.combined(with: .blurReplace))
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .all)
            }
        }
        .fullScreenCover(isPresented: $expandWorkout) {
            if let ongoingWorkout, expandWorkout {
                NavigationStack{
                    WorkoutEdit(appDatabase: appDatabase, workout: ongoingWorkout)
                    
                }
                .navigationTransition(.zoom(sourceID: "MINIWORKOUT", in: animation))
            }
        }
        .animation(.easeInOut, value: expandWorkout)
        .animation(.default, value: ongoingWorkout)
    }
    @ViewBuilder
    func startWorkoutButton() -> some View {
        Button {
            Task{@MainActor in
                do {
                    try await appDatabase.startWorkout(name: "New Workout", notes: "")
                        expandWorkout = true
                    
                }catch {
                    
                }
            }
        }label: {
            Image(systemName: "plus")
                .font(.title.bold())
        }
        .frame(width: 60, height: 60)
        .tint(.theme.primary)
        .offset(y: -52)
        .padding(.horizontal, 15)
    }
    
    /// Resuable Workout Info
    @ViewBuilder
    func WorkoutInfo(_ name: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.callout.bold())
            }
            .padding(.leading, 10)
            .lineLimit(1)
        }
    }
    
    /// MiniWorkout View
    @ViewBuilder
    func MiniWorkoutView(_ ongoingWorkout: WorkoutRecord) -> some View {
        HStack(spacing: 15) {
            WorkoutInfo(ongoingWorkout.name)
            
            Spacer(minLength: 0)
            
            WorkoutTimer(date: ongoingWorkout.creationDate!)
        }
        .foregroundStyle(Color.primary)
        .padding(.horizontal, 15)
    }
}

private struct OngoingWorkoutQuery: ValueObservationQueryable {
    static var defaultValue: WorkoutRecord? { nil }
    
    func fetch(_ db: Database) throws -> WorkoutRecord? {
        try WorkoutRecord.filter{$0.endDate == nil}.fetchOne(db)
    }
}

#Preview {
    ContentView()
        .appDatabase(.withBodyweightExercises())
}
