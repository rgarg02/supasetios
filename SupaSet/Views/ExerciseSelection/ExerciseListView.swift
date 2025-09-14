//
//  ExerciseListView.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import SwiftUI

struct ExerciseListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExerciseListViewModel
    @State private var selectedIDs = [String]()
    let selectingMultiple : Bool
    let onAdd: ([String]) -> Void  // still returns an array in selection order
    init(appDatabase: AppDatabase, onAdd: @escaping ([String]) -> Void, selectingMultiple: Bool = true) {
        self.onAdd = onAdd
        _viewModel = State(initialValue: ExerciseListViewModel(appDatabase: appDatabase))
        self.selectingMultiple = selectingMultiple
    }

    var body: some View {
        List {
            ForEach(viewModel.exercises) { exercise in
                ExerciseSelctionRow(exercise: exercise)
                    .background(selectedIDs.contains(exercise.id) ? Color.secondary : Color.clear)
                    .onTapGesture {
                        if selectingMultiple {
                            if let idx = selectedIDs.firstIndex(of: exercise.id) {
                                selectedIDs.remove(at: idx)
                            } else {
                                selectedIDs.append(exercise.id)
                            }
                        } else {
                            selectedIDs = [exercise.id]
                        }
                    }
            }

            // sentinel for pagination
            if !viewModel.allExercisesLoaded {
                sentinelView
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !selectedIDs.isEmpty {
                    Button("^[\(selectingMultiple ? "Add" : "Replace") \(selectedIDs.count) exercise](inflect: true)") {
                        onAdd(selectedIDs)
                        dismiss()
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText)
        .onAppear {
            if viewModel.exercises.isEmpty {
                Task { await viewModel.loadMoreExercises() }
            }
        }
    }

    @ViewBuilder
    private var sentinelView: some View {
        if viewModel.isLoading {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        } else {
            Color.clear
                .onAppear {
                    Task { await viewModel.loadMoreExercises() }
                }
        }
    }
}
