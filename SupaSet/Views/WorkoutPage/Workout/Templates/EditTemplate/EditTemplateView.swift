import SwiftUI

struct EditTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var templateVM: TemplateVM
    let isNew: Bool
    let appDatabase: AppDatabase
    @State private var toolbarVC = ToolbarVC()
    @State private var showKeyboardButtons = false
    @State private var showDistribution = false
    @State private var activePrimaryMuscles: Set<MuscleGroup> = []
    @State private var activeSecondaryMuscles: Set<MuscleGroup> = []
    
    @Namespace var namespace
    init(appDatabase: AppDatabase, workoutTemplate: WorkoutTemplate? = nil, fullTemplateExercises: [FullTemplateExercise]? = nil){
        self._templateVM = State(initialValue: TemplateVM(template: workoutTemplate, appDatabase: appDatabase))
        self.appDatabase = appDatabase
        self.isNew = workoutTemplate == nil && fullTemplateExercises == nil
    }
    var body: some View {
        ScrollView {
            VStack {                NameEditor(name: $templateVM.template.name) { newName in
                    templateVM.updateTemplateName(to: newName)
                }
                RecordInfo(creationDate: templateVM.template.creationDate ?? .now, modificationDate: templateVM.template.modificationDate ?? .now, showTimer: false, notes: $templateVM.template.notes) { newNotes in
                    templateVM.updateTemplateNotes(to: newNotes)
                }
                TemplateExercisesView(templateVM: templateVM)
                AddExercisesButton()
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
                        templateVM.deleteTemplate()
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
                    templateVM.finishTemplate()
                    dismiss()
                }label:{
                    Text(templateVM.isNew ? "Add" : "Save")
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
                        activePrimaryMuscles = try await templateVM.fetchActivePrimaryMuscles()
                        activeSecondaryMuscles = try await templateVM.fetchActiveSecondaryMuscles()
                    } catch {
                        
                    }
                }
        }
        
    }
}
extension EditTemplateView {
    @ViewBuilder
    func AddExercisesButton() -> some View {
        VStack {
            NavigationLink {
                ExerciseListView(appDatabase: appDatabase) { exercises in
                    templateVM.addExercisesToTemplate(exerciseIds: exercises)
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
