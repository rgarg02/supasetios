//
//  ExerciseListViewModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import SwiftUI
import Observation
import GRDB

@MainActor
@Observable
final class ExerciseListViewModel {
    var exercises: [ExerciseJSON] = []
    var isLoading = false
    var allExercisesLoaded = false

    // This property is bound to the search field in the UI.
    var searchText: String = "" {
        didSet {
            // When text changes, cancel any previous search task and start a new one.
            searchTask?.cancel()
            searchTask = Task {
                // Debounce for 150ms before performing the search.
                do {
                    try await Task.sleep(for: .milliseconds(150))
                    await performSearch()
                } catch {
                    // Task was cancelled, which is expected. Do nothing.
                }
            }
        }
    }

    // This property holds the value that is actually used for the database query.
    private(set) var debouncedText: String = ""

    private var currentPage = 0
    private let itemsPerPage = 20
    private let appDatabase: AppDatabase
    private var searchTask: Task<Void, Error>? // Task to manage the debouncing

    init(appDatabase: AppDatabase) {
        self.appDatabase = appDatabase
    }

    /// Performs a new search by resetting the state and loading the first page.
    private func performSearch() async {
        // Update the debounced text to match the search text.
        debouncedText = searchText

        // Reset pagination and results.
        currentPage = 0
        exercises = []
        allExercisesLoaded = false

        // Load the first page of the new search results.
        await loadMoreExercises()
    }

    /// Fetches the next page of exercises from the database.
    /// Can be called for both new searches and subsequent pagination.
    func loadMoreExercises() async {
        guard !isLoading && !allExercisesLoaded else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // Use the debouncedText for the query.
            let fetchedExercises = try await appDatabase.fetchCompleteExercises(
                limit: itemsPerPage,
                offset: currentPage * itemsPerPage,
                searchText: debouncedText
            )

            if fetchedExercises.isEmpty {
                allExercisesLoaded = true
            } else {
                exercises.append(contentsOf: fetchedExercises)
                currentPage += 1
            }
        } catch {
            print("Failed to fetch exercises: \(error.localizedDescription)")
            // Handle error, e.g., show an alert
        }
    }
}
