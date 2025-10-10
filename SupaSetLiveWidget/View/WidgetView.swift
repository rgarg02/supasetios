// WorkoutLiveActivityView.swift

import SwiftUI
import WidgetKit

struct WorkoutLiveActivityView: View {
    let context: ActivityViewContext<WorkoutAttributes>
    
    var body: some View {
        VStack(spacing: 5) {
            // Top Row: Workout Name and Timer
            HStack {
                Label(context.state.workoutName, systemImage: "dumbbell.fill")
                    .font(.callout.bold())
                Spacer()
                TimerText(startTime: context.attributes.startTime, alignment: .leading)
            }
            .foregroundStyle(.secondary)
            
            // Exercise Name and Progress
            HStack(alignment: .center) {
                Text(context.state.exerciseName)
                    .font(.title3.bold())
                    .lineLimit(1)
                Spacer()
                progressPills
            }
            
            // Weight and Reps Controls
            HStack(spacing: 16) {
                ValueControlView(
                    label: AnyView(EmptyView()), // No label needed for horizontal
                    value: "\(Int(context.state.weight))kg",
                    decreaseIntent: DecreaseWeightIntent(),
                    increaseIntent: IncreaseWeightIntent(),
                    layout: .horizontal
                )
                ValueControlView(
                    label: AnyView(EmptyView()), // No label needed for horizontal
                    value: "\(context.state.reps) reps",
                    decreaseIntent: DecreaseRepsIntent(),
                    increaseIntent: IncreaseRepsIntent(),
                    layout: .horizontal
                )
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 4)
            
            // Complete Set Button
            CompleteSetToggle(isCompleted: context.state.setCompleted, intent: CompleteSetIntent())
        }
        .foregroundStyle(Color.theme.text)
        .padding(12)
    }
    
    private var progressPills: some View {
        HStack(spacing: 4) {
            Text("Set \(context.state.currentSetNumber + 1)/\(context.state.totalSets)")
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.theme.primary.opacity(0.5))
                .clipShape(Capsule())
            
            if context.state.setType != .working {
                Text(context.state.setType.description)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(context.state.setType.color.opacity(0.15))
                    .foregroundStyle(context.state.setType.color)
                    .clipShape(Capsule())
            }
        }
        .font(.caption.bold())
    }
}
