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
    @Query(OngoingWorkoutQuery())
    private var ongoingWorkout: WorkoutRecord?
    @State private var expandWorkout: Bool = false
    @State private var tab: Tabs = .home
    @Namespace private var animation
    enum Tabs {case home, profile, history}
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                NativeTabView()
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
                
            } else {
                NativeTabView(60)
                    .overlay(alignment: .bottom) {
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
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .all)
            }
        }
        .fullScreenCover(isPresented: $expandWorkout) {
            if let ongoingWorkout, expandWorkout {
                WorkoutCoverView(workout: ongoingWorkout, animation: animation)
                    .navigationTransition(.zoom(sourceID: "MINIWORKOUT", in: animation))
            }
        }
        .animation(.easeInOut, value: expandWorkout)
    }
    
    /// Let's First Start with TabView
    @ViewBuilder
    func NativeTabView(_ safeAreaBottomPadding: CGFloat = 0) -> some View {
        TabView(selection: $tab) {
            Tab.init("Home", systemImage: "house.fill", value: .home) {
                NavigationStack {
                    WorkoutPageView()
                        .navigationTitle("Home")
                        .safeAreaPadding(.bottom, safeAreaBottomPadding)
                        .background(Color.theme.bg_dark)
                }
            }
            Tab.init("History", systemImage: "calendar", value: .history) {
                    HistoryPageView()
                        .safeAreaPadding(.bottom, safeAreaBottomPadding)
                        .background(Color.theme.bg_dark)
            }
            Tab.init("Profile", systemImage: "square.grid.2x2.fill", value: .profile) {
                NavigationStack {
                    ProfilePageView()
                        .navigationTitle("Profile")
                        .safeAreaPadding(.bottom, safeAreaBottomPadding)
                        .background(Color.theme.bg_dark)
                }
            }
        }
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
