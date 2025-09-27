import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutTemplate : WorkoutTemplate
    @State private var templateExercises : [TemplateExerciseWithSets]
    let isNew: Bool
    @State private var toolbarVC = ToolbarVC()
    @State private var showKeyboardButtons = false
    @Environment(\.appDatabase) private var appDatabase
    @Namespace var namespace
    init(workoutTemplate: WorkoutTemplate? = nil, templateExercisesWithSets: [TemplateExerciseWithSets]? = nil){
        self.isNew = workoutTemplate == nil && templateExercisesWithSets == nil
        if let workoutTemplate, let templateExercisesWithSets {
            self.workoutTemplate = workoutTemplate
            self.templateExercises = templateExercisesWithSets
        }else {
            self.workoutTemplate = WorkoutTemplate(name: "New Template", notes: "")
            self.templateExercises = []
        }
    }
    var body: some View {
        VStack {
            ScrollView {
                TemplateNameEditor(templateName: workoutTemplate.name) { newName in
                    workoutTemplate.name = newName
                }
                TemplateRecordInfo(template: workoutTemplate) { newNotes in
                    workoutTemplate.notes = newNotes
                }
                EditTemplateExercisesView(templateExercisesWithSet: $templateExercises)
                AddExercisesButton()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Button {
                    saveTemplate()
                    dismiss()
                } label: {
                    Label("Finish", systemImage: "flag.pattern.checkered")
                }
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            if showKeyboardButtons {
                ToolbarControls(toolbarVC: toolbarVC)
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
        .environment(toolbarVC)
        
    }
    func saveTemplate() {
        print(templateExercises.count)
        Task { @MainActor in
            do {
                let template = try await appDatabase.savedTemplate(workoutTemplate)
                guard let templateId = template.id else {
                    return
                }
                for templateExercise in templateExercises {
                    var exercise = templateExercise.templateExercise
                    exercise.templateId = templateId
                    do {
                        exercise = try await appDatabase.savedTemplateExercise(exercise)
                    } catch {
                    }
                    let sets = templateExercise.templateSets
                    guard let exerciseID = exercise.id else {
                        continue
                    }
                    for set in sets {
                        var templateSet = set
                        templateSet.templateExerciseId = exerciseID
                        do {
                            templateSet = try await appDatabase.savedTemplateSet(templateSet)
                        } catch {
                        }
                    }
                }
            } catch {
            }
        }
    }
    func addExercisesTemplate(exerciseIds: [String]) {
        for exerciseId in exerciseIds {
            let templateExercise = TemplateExercise(exerciseID: exerciseId, order: templateExercises.count)
            let templateSet = TemplateExerciseSet(type: .working, order: 0)
            withAnimation(.easeInOut) {
                templateExercises.append(.init(templateExercise: templateExercise, templateSets: [templateSet]))
            }
        }
    }
    
    @ViewBuilder
    func AddExercisesButton() -> some View {
        VStack{
            NavigationLink {
                ExerciseListView(appDatabase: appDatabase) { exercises in
                    addExercisesTemplate(exerciseIds: exercises)
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

#Preview {
    NavigationStack {
        EditTemplateView()
            .appDatabase(.withBodyweightExercises())
    }
}
