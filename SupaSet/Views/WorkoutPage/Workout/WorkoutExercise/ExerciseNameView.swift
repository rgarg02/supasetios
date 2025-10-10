//
//  ExerciseNameView.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//


import SwiftUI
import GRDBQuery
import GRDB
struct ExerciseNameView: View {
    let exerciseID: String
    @State private var name: String = ""
    @Environment(\.appDatabase) private var appDatabase
    var body: some View {
        Text("\(name == "" ? exerciseID : name)")
            .font(.title2.bold())
            .lineLimit(1)
            .task {
                await fetchName()
            }
            .onChange(of: exerciseID) { oldValue, newValue in
                Task {
                    await fetchName()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    @MainActor
    func fetchName() async {
        do {
            name = try await appDatabase.fetchExerciseName(for: exerciseID) ?? ""
        } catch {
            
        }
    }
}
