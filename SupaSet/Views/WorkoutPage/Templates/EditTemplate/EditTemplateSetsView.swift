import SwiftUI

// This view is now generic over any type conforming to ExerciseSetProtocol.
struct EditSetsView<ExerciseSet: ExerciseSetProtocol>: View {
    @Environment(\.appDatabase) private var appDatabase
    @Binding var sets: [ExerciseSet]
    let padding: CGFloat
    let exerciseOrder: Int
    let spacing: CGFloat = 5

    var body: some View {
        // Loop over the binding of sets. Use \.self for ID since the set is Hashable.
        ForEach($sets, id: \.self) { $set in
            let workingSetOrder = sets.filter({ $0.setType == .working && $0.order < set.order }).count
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        SetTypeIndicatorView(exerciseSetType: set.setType, setOrder: workingSetOrder) { newType in
                            set.setType = newType
                        }
                        HStack(spacing: spacing) {
                            WeightView(
                                weight: set.weight,
                                isDone: false, // You might want to add `isDone` to the protocol if needed here
                                fieldType: .weight(exerciseOrder, set.order)
                            ) { newWeight in
                                set.weight = newWeight
                            }
                            .frame(width: 100)
                            
                            HStack {
                                Group {
                                    // Use the repType from the protocol.
                                    switch set.repType {
                                    case .reps(let reps):
                                        TemplateRepsView(reps: reps, repType: set.repType, fieldType: .reps(exerciseOrder, set.order)) { newReps in
                                            set.repType = .reps(newReps)
                                        }
                                    case .range(let lowerBound, let upperBound):
                                        TemplateRepsView(reps: lowerBound, repType: set.repType, fieldType: .reps(exerciseOrder, set.order)) { newLowerBound in
                                            let upperUnwrapped = upperBound ?? newLowerBound
                                            set.repType = .range(newLowerBound, upperUnwrapped)
                                        }
                                        Text("-")
                                        TemplateRepsView(reps: upperBound, repType: set.repType, fieldType: .reps(exerciseOrder, set.order, 1)) { newUpperBound in
                                            let lowerUnwrapped = lowerBound ?? newUpperBound
                                            set.repType = .range(lowerUnwrapped, newUpperBound)
                                        }
                                    }
                                }
                                // Conditionally show the Menu button based on the protocol property.
                                if set.supportsRange {
                                    Menu {
                                        Button("Reps") { set.repType = .reps(nil) }
                                        Button("Range") { set.repType = .range(nil, nil) }
                                    } label: {
                                        Image(systemName: set.repType.description == "Reps" ? "textformat.123" : "arrow.left.and.right")
                                            .modifier(MenuIconStyle())
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(width: UIScreen.main.bounds.size.width - 40 - spacing - 2 * padding - padding)
                    }
                    .frame(height: 50)
                    .padding(.horizontal, padding / 2)
                    .ignoresSafeArea()
                    .background(.clear)
                }
            }
            .scrollDisabled(true)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            .cornerRadius(12)
        }
    }
}

// Helper view modifier to avoid code repetition for the menu icon style.
struct MenuIconStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .fontWeight(.bold)
            .frame(width: 40, height: 40)
            .contentTransition(.symbolEffect(.replace, options: .speed(2)))
            .foregroundStyle(.primary)
            .background(.regularMaterial, in: .circle)
    }
}
