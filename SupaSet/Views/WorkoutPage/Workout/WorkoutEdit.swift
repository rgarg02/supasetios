//
//  WorkoutEditNew.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI

struct WorkoutEdit: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var workoutVM: WorkoutVM
    @State private var toolbarVC = ToolbarVC()
    let appDatabase: AppDatabase
    @Namespace private var namespace
    @State private var activePrimaryMuscles: Set<MuscleGroup> = []
    @State private var activeSecondaryMuscles: Set<MuscleGroup> = []
    @State private var timerOpacity = CGFloat.zero
    @State private var timerBlur = CGFloat.zero
    @State private var isTimerVisible = false
    @State private var showKeyboardButtons = false
    @State private var showDistribution = false
    init(appDatabase: AppDatabase, workout: WorkoutRecord, isNew: Bool = true ) {
        self.appDatabase = appDatabase
        self._workoutVM = State(initialValue: WorkoutVM(workout: workout, appDatabase: appDatabase, isNew: isNew))
    }
    var body: some View {
        ScrollView {
            VStack {
                NameEditor(name: $workoutVM.workout.name) { newName in
                    workoutVM.updateWorkoutName(to: newName)
                }
                RecordInfo(creationDate: workoutVM.workout.creationDate ?? .now, endDate: workoutVM.workout.endDate, modificationDate: workoutVM.workout.modificationDate ?? .now, notes: $workoutVM.workout.notes) { newNotes in
                    workoutVM.updateWorkoutNotes(to: newNotes)
                }
                WorkoutExercisesView(workoutVM: workoutVM)
                AddExercisesButton()
            }
        }
        .onChange(of: isTimerVisible) { oldValue, newValue in
            withAnimation(.snappy(duration: 0.65, extraBounce: 0.07)) {
                timerOpacity = timerOpacity == 0 ? 1 : 0
                timerBlur = timerBlur == 0 ? 0 : 1
            }
        }
        .environment(toolbarVC)
        .background(LinearGradient(colors: [.bg, .bgDark], startPoint: .top, endPoint: .bottom))
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        workoutVM.deleteWorkout()
                    }
                }label: {
                    Image(systemName: "trash.fill")
                        .font(.title3.bold())
                }
                .tint(.theme.danger)
                .buttonStyle(.borderedProminent)
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
                    workoutVM.finishWorkout()
                    dismiss()
                }label:{
                    Text(workoutVM.isNew ? "Finish" : "Save")
                        .font(.title3.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(.theme.secondary)
            }
        }
        .sheet(isPresented: $showDistribution) {
            activePrimaryMuscles = []
            activeSecondaryMuscles = []
        } content: {
            MuscleDistributionView(activePrimaryMuscles: activePrimaryMuscles, activeSecondaryMuscles: activeSecondaryMuscles)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
                .task {
                    do {
                        activePrimaryMuscles = try await workoutVM.fetchActivePrimaryMuscles()
                        activeSecondaryMuscles = try await workoutVM.fetchActiveSecondaryMuscles()
                    } catch {
                        
                    }
                }
        }
    }
}

extension WorkoutEdit {
    @ViewBuilder
    func AddExercisesButton() -> some View {
        VStack {
            NavigationLink {
                ExerciseListView(appDatabase: appDatabase) { exercises in
                    workoutVM.addExercisesToWorkout(exerciseIds: exercises)
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
            .glassButtonStyle(tintColor: .theme.primary, cornerRadius: 12)
        }
        .padding(10)
    }
}
