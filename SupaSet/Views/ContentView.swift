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
    @State private var selectedTab: Tabs = .home
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
                WorkoutCoverView(workout: ongoingWorkout)
                    .navigationTransition(.zoom(sourceID: "MINIWORKOUT", in: animation))
            }
        }
        .background(.red)
        .animation(.easeInOut, value: expandWorkout)
    }
    
    /// Let's First Start with TabView
    @ViewBuilder
    func NativeTabView(_ safeAreaBottomPadding: CGFloat = 0) -> some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WorkoutPageView()
                    .navigationTitle("Home")
                    .safeAreaPadding(.bottom, safeAreaBottomPadding)
                    .background(LinearGradient(colors: [.bg, .bgDark], startPoint: .top, endPoint: .bottom))
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button {
                                Task {
                                    do {
                                        if ongoingWorkout == nil {
                                            try await appDatabase.startWorkout(name: "New Workout", notes: "")
                                        } else {
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
            .tabItem {
                Label {
                    Text("Home")
                } icon: {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        .symbolVariant(.none)
                        .environment(\.symbolVariants, .none)
                }
            }
            .tag(Tabs.home)
            
            NavigationStack {
                HistoryPageView()
                    .safeAreaPadding(.bottom, safeAreaBottomPadding)
                    .background(LinearGradient(colors: [.bg, .bgDark], startPoint: .top, endPoint: .bottom))
            }
            .tabItem {
                Label {
                    Text("History")
                } icon: {
                    Image(systemName: selectedTab == .history ? "list.bullet.clipboard.fill" : "list.bullet.clipboard")
                        .environment(\.symbolVariants, .none)
                }
            }
            .tag(Tabs.history)
            
            // Profile Tab
            NavigationStack {
                ProfilePageView()
                    .safeAreaPadding(.bottom, safeAreaBottomPadding)
                    .background(LinearGradient(colors: [.bg, .bgDark], startPoint: .top, endPoint: .bottom))
            }
            .tabItem {
                Label {
                    Text("Profile")
                } icon: {
                    Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                        .environment(\.symbolVariants, .none)
                }
            }
            .tag(Tabs.profile)
        }
        // Apply the tint to the entire TabView
        .tint(Color.theme.primary)
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
