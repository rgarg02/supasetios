//
//  WorkoutEditView.swift
//  SupaSet
//
//  Created by Rishi Garg on 7/7/25.
//


import SwiftUI
import GRDB

struct WorkoutEditView: View {
    let workout: WorkoutRecord
    
    // States
    @Environment(\.appDatabase) private var appDatabase
    @Namespace var namespace
    @State private var opacity = CGFloat.zero
    @State private var blur = CGFloat.zero
    @State private var isTimerVisible = false
    @State private var showKeyboardButtons = false
    @State private var offset : CGFloat = .zero
    @State private var toolbarVC = ToolbarVC()
    init(workout: WorkoutRecord) {
        self.workout = workout
    }
    var body: some View {
        ScrollView{
            VStack{
                WorkoutNameEditor(workout: workout)
                WorkoutRecordInfo(workout: workout)
                    .onScrollVisibilityChange { changed in
                        isTimerVisible = !changed
                    }
                WorkoutExercisesView(workoutID: workout.id!)
                AddExercisesButton()
            }
        }
        .environment(toolbarVC)
        .scrollDismissesKeyboard(.interactively)
        .toolbarTitleDisplayMode(.inline)
        .onChange(of: isTimerVisible) { oldValue, newValue in
            withAnimation(.snappy(duration: 0.65, extraBounce: 0.07)){
                opacity = opacity == 0 ? 1 : 0
                blur = blur == 0 ? 0 : 1
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                WorkoutTimer(date: workout.creationDate ?? .now)
                    .opacity(opacity)
                    .blur(radius: blur)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            if showKeyboardButtons {
                HStack {
                    Spacer()
                    if toolbarVC.fieldType != nil {
                        Button {
                            toolbarVC.moveToNextField()
                        } label: {
                            Image(systemName: "arrowshape.right")
                        }
                        .modify {
                            if #available(iOS 26, *) {
                                $0
                                    .buttonStyle(.glass)
                                    .clipShape(.rect(corners: .concentric(), isUniform: true))
                            }
                        }
                        
                    }
                }
                .padding(3)
                .containerShape(.rect(cornerRadius: 12))
                .background(.thinMaterial, in: .rect(cornerRadius: 12))
                .padding(.horizontal)
                .transition(.blurReplace)
            }
        })
        .animation(.bouncy(duration: 0.25), value: showKeyboardButtons)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { noti in
                DispatchQueue.main.async { self.showKeyboardButtons = true }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { noti in
                DispatchQueue.main.async {
                    self.showKeyboardButtons = false
                    toolbarVC.fieldType = nil
                }
            }
        }
    }
    func addExercisesToWorkout(exerciseIds: [String]) {
        Task { @MainActor in
            do {
                try await appDatabase.addExercisesToWorkoutWithPreviousSets(exerciseIds: exerciseIds, to: workout.id!)
            } catch {
                
            }
        }
    }
    
    @ViewBuilder
    func AddExercisesButton() -> some View {
        VStack{
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
            .modify {
                if #available(iOS 26, *) {
                    $0
                        .glassEffect(.clear.interactive().tint(.red.mix(with: .green, by: 0.5)), in: .rect(cornerRadius: 12))
                }else {
                    $0
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
        }
        .padding(10)
    }
}

