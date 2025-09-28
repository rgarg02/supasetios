//
//  WorkoutEditView.swift
//  SupaSet
//
//  Created by Rishi Garg on 7/7/25.
//

import SwiftUI
import GRDB
import GRDBQuery
struct WorkoutEditView: View {
    // MARK: - Properties
    
    let workout: WorkoutRecord
    
    // Environment
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.dismiss) private var dismiss
    
    // Namespace for matched geometry effects
    @Namespace private var namespace
    
    // State variables for UI management
    @State private var opacity = CGFloat.zero
    @State private var blur = CGFloat.zero
    @State private var isTimerVisible = false
    @State private var showKeyboardButtons = false
    @State private var showDistribution = false
    @Query<ActivePrimaryMuscleRequest>
    private var activePrimaryMuscles: Set<MuscleGroup>
    @Query<ActiveSecondaryMusclesRequest>
    private var activeSecondaryMuscles: Set<MuscleGroup>
    // Toolbar controller instance
    @State private var toolbarVC = ToolbarVC()
    
    // MARK: - Initializer
    
    init(workout: WorkoutRecord) {
        self.workout = workout
        self._activePrimaryMuscles = Query(ActivePrimaryMuscleRequest(workoutId: workout.id!))
        self._activeSecondaryMuscles = Query(ActiveSecondaryMusclesRequest(workoutId: workout.id!))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    WorkoutNameEditor(workout: workout)
                    
                    WorkoutRecordInfo(workout: workout)
                        .onScrollVisibilityChange { changed in
                            isTimerVisible = !changed
                        }
                    
                    WorkoutExercisesView(workoutID: workout.id!)
                    
                    AddExercisesButton()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    }label: {
                        Image(systemName: "trash.fill")
                            .font(.title3.bold())
                    }
                    .tint(.theme.danger)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDistribution = true
                    } label: {
                        Image(systemName: "figure")
                            .font(.title3.bold())
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        finishWorkout()
                        dismiss()
                    }label:{
                        Image(systemName: "trophy.fill")
                            .font(.title3.bold())
                    }
                    .tint(.theme.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [.bg, .bgDark], startPoint: .top, endPoint: .bottom))
            .environment(toolbarVC)
            .scrollDismissesKeyboard(.interactively)
            .toolbarTitleDisplayMode(.inline)
            .onChange(of: isTimerVisible) { oldValue, newValue in
                withAnimation(.snappy(duration: 0.65, extraBounce: 0.07)) {
                    opacity = opacity == 0 ? 1 : 0
                    blur = blur == 0 ? 0 : 1
                }
            }
            .safeAreaInset(edge: .bottom) {
                if showKeyboardButtons {
                    ToolbarControls(toolbarVC: toolbarVC)
                }
            }
            .animation(.bouncy(duration: 0.25), value: showKeyboardButtons)
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    DispatchQueue.main.async { showKeyboardButtons = true }
                }
                
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    DispatchQueue.main.async {
                        showKeyboardButtons = false
                        toolbarVC.fieldType = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showDistribution, content: {
            MuscleDistributionView(activePrimaryMuscles: activePrimaryMuscles, activeSecondaryMuscles: activeSecondaryMuscles)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        })
    }
}

// MARK: - Private Methods

private extension WorkoutEditView {
    func finishWorkout() {
        Task { @MainActor in
            do {
                var updatedWorkout = workout
                updatedWorkout.endDate = Date()
                _ = try await appDatabase.updateWorkout(updatedWorkout)
            } catch {
                // Handle error if needed
            }
        }
    }
    
    func addExercisesToWorkout(exerciseIds: [String]) {
        Task { @MainActor in
            do {
                try await appDatabase.addExercisesToWorkoutWithPreviousSets(exerciseIds: exerciseIds, to: workout.id!)
            } catch {
                // Handle error if needed
            }
        }
    }
    
    @ViewBuilder
    func AddExercisesButton() -> some View {
        VStack {
            NavigationLink {
                ExerciseListView(appDatabase: appDatabase) { exercises in
                    addExercisesToWorkout(exerciseIds: exercises)
                }
                .navigationTransition(.zoom(sourceID: "zoomSource", in: namespace))
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Exercises")
                }
                .matchedTransitionSource(id: "zoomSource", in: namespace)
                .padding(10)
                .frame(maxWidth: .infinity)
            }
            .contentShape(.rect)
            .foregroundStyle(.primary)
            .modify({ view in
                if #available(iOS 26, *) {
                    view
                        .glassEffect(.regular.interactive().tint(.theme.primary.opacity(0.6)), in: .rect(cornerRadius: 12))
                } else {
                    view
                        .background(Color.theme.primary, in: .rect(cornerRadius: 12))
                }
            })
        }
        .padding(10)
    }
}
