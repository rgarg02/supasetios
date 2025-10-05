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
    @State private var tab: Tabs = .home
    @State private var workoutVM: WorkoutVM?
    @Namespace private var animation
    enum Tabs {case home, profile, history, actionButton}
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
                    .overlay(alignment: .bottomTrailing) {
                        if ongoingWorkout == nil {
                            startWorkoutButton()
                                .buttonStyle(.glass)
                                .transition(.scale.combined(with: .blurReplace))
                        }
                    }
                    .animation(.default, value: ongoingWorkout)
            } else {
                NativeTabView(60)
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
        .onAppear {
            if let ongoingWorkout {
                workoutVM = WorkoutVM(workout: ongoingWorkout, appDatabase: appDatabase, isNew: true)
            }
        }
        .onChange(of: ongoingWorkout, { oldValue, newValue in
            if let newValue {
                workoutVM = WorkoutVM(workout: newValue, appDatabase: appDatabase, isNew: true)
            }else {
                workoutVM = nil
            }
        })
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
    /// Let's First Start with TabView
    @ViewBuilder
    func NativeTabView(_ safeAreaBottomPadding: CGFloat = 0) -> some View {
        TabView(selection: $tab) {
            Tab(value: .home) {
                NavigationStack {
                    WorkoutPageView()
                        .navigationTitle("Home")
                        .safeAreaPadding(.bottom, safeAreaBottomPadding)
                        .background(LinearGradient(colors: [.bgDark, .bg], startPoint: .top, endPoint: .bottom))
                }
            } label : {
                Label("Home", systemImage: tab == .home ? "house.fill" : "house")
                    .environment(\.symbolVariants, .none)
            }
            Tab(value: .history) {
                NavigationStack {
                    HistoryPageView()
                        .safeAreaPadding(.bottom, safeAreaBottomPadding)
                        .background(LinearGradient(colors: [.bgDark, .bg], startPoint: .top, endPoint: .bottom))
                }
            } label : {
                Label("History", systemImage: tab == .history ? "list.bullet.clipboard.fill" : "list.bullet.clipboard")
                    .environment(\.symbolVariants, .none)
            }
            Tab(value: .profile) {
                NavigationStack {
                    ProfilePageView()
                        .navigationTitle("Profile")
                        .safeAreaPadding(.bottom, safeAreaBottomPadding)
                        .background(LinearGradient(colors: [.bgDark, .bg], startPoint: .top, endPoint: .bottom))
                }
            } label : {
                Label("Profile", systemImage: tab == .profile ? "person.fill" : "person")
                    .environment(\.symbolVariants, .none)
            }
        }
        .tint(.theme.primary)
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
