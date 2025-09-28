import SwiftUI

// The view is now generic over any type that conforms to ExerciseWithSetsProtocol.
struct EditExercisesView<ExerciseWrapper: ExerciseWithSetsProtocol>: View {
    @Environment(\.appDatabase) private var appDatabase
    // The binding is now to an array of the generic type.
    @Binding var exercisesWithSets: [ExerciseWrapper]
    @State private var exercisesName: [String: String] = [:]
    let padding: CGFloat = 10

    var body: some View {
        // Loop over the binding to allow mutations to each element.
        ForEach($exercisesWithSets, id: \.exercise) { $exerciseWithSet in
            VStack {
                HStack {
                    // Access properties through the protocol.
                    ExerciseNameView(exerciseId: exerciseWithSet.exercise.exerciseID)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ExerciseOptions {
                        deleteExercise(exerciseWithSet.exercise)
                    } replaceExercise: { exerciseID in
                        if let exerciseID {
                            // The exerciseID property is settable via the protocol.
                            exerciseWithSet.exercise.exerciseID = exerciseID
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                ExerciseSetsColumnNames()
                
                // Pass the binding for the sets to the generic subview.
                EditSetsView(
                    sets: $exerciseWithSet.sets,
                    padding: padding,
                    exerciseOrder: exerciseWithSet.exercise.order
                )
                
                PlaceholderSetView(onTap: {
                    withAnimation(.easeInOut) {
                        // Call the protocol method to add a new set.
                        exerciseWithSet.addNewSet()
                    }
                })
            }
            .padding(padding)
        }
        .onAppear(perform: updateNames)
        .onChange(of: exercisesWithSets.map { $0.exercise.exerciseID }) { _, _ in
            updateNames()
        }
    }

    private func updateNames() {
        Task {
            var names: [String: String] = [:]
            for item in exercisesWithSets {
                if let name = try await appDatabase.fetchExerciseName(for: item.exercise.exerciseID) {
                    names[item.exercise.exerciseID] = name
                }
            }
            exercisesName = names
        }
    }

    private func deleteExercise(_ exercise: ExerciseWrapper.Exercise) {
        exercisesWithSets.removeAll(where: { $0.exercise == exercise })
    }

    @ViewBuilder
    func ExerciseSetsColumnNames() -> some View {
        HStack(spacing: 5) {
            Text("Set").frame(width: 40)
            Text("Weight").frame(width: 100)
            Text("Reps").frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
