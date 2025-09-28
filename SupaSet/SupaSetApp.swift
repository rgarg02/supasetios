//
//  SupaSetApp.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/25/25.
//

import SwiftUI
import GRDBQuery
@main
struct SupaSetApp: App {
    @State private var selectedMusce: MuscleGroup?
    var body: some Scene {
        WindowGroup {
            ContentView()
                .appDatabase(.shared)
        }
    }
}
// MARK: - Give SwiftUI access to the database

extension EnvironmentValues {
    @Entry var appDatabase = AppDatabase.empty()
}

extension View {
    func appDatabase(_ appDatabase: AppDatabase) -> some View {
        self.environment(\.appDatabase, appDatabase)
        .databaseContext(.readOnly { appDatabase.reader })
    }
}
