//
//  NativeTabView.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//

import SwiftUI

struct NativeTabView: View {
    @Environment(\.appDatabase) private var appDatabase
    enum Tabs {case home, profile, history, actionButton}
    let safeAreaBottomPadding: CGFloat
    @State private var tab: Tabs = .home
    init(_ safeAreaBottomPadding: CGFloat = 0, appDatabase: AppDatabase) {
        self.safeAreaBottomPadding = safeAreaBottomPadding
    }
    var body: some View {
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
        .onAppear {
            WorkoutActivityManager.shared.setDatabase(appDatabase)
        }
    }
}
