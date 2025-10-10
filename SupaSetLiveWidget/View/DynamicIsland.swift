// SupaSetWidget.swift

import WidgetKit
import SwiftUI
import ActivityKit
import AppIntents

struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            WorkoutLiveActivityView(context: context)
                .containerBackground(.fill.tertiary, for: .widget)
                .background(Color.theme.bg)
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: - Expanded Leading Region
                DynamicIslandExpandedRegion(.leading) {
                    ValueControlView(
                        label: AnyView(Image(systemName: "dumbbell.fill").padding(.leading)),
                        value: "\(Int(context.state.weight))kg",
                        decreaseIntent: DecreaseWeightIntent(),
                        increaseIntent: IncreaseWeightIntent(),
                        layout: .vertical
                    )
                }
                
                // MARK: - Expanded Trailing Region
                DynamicIslandExpandedRegion(.trailing) {
                    ValueControlView(
                        label: AnyView(TimerText(startTime: context.attributes.startTime, alignment: .leading)),
                        value: "\(context.state.reps) reps",
                        decreaseIntent: DecreaseRepsIntent(),
                        increaseIntent: IncreaseRepsIntent(),
                        layout: .vertical
                    )
                }
                
                // MARK: - Expanded Center Region
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text(context.state.exerciseName)
                            .font(.title3.bold())
                            .lineLimit(1)
                        Text("Set \(context.state.currentSetNumber + 1)/\(context.state.totalSets)")
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.theme.secondary.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(Color.text)
                }
                
                // MARK: - Expanded Bottom Region
                DynamicIslandExpandedRegion(.bottom) {
                    CompleteSetToggle(isCompleted: context.state.setCompleted, intent: CompleteSetIntent())
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .font(.callout.bold())
            } compactTrailing: {
                TimerText(startTime: context.attributes.startTime, alignment: .center)
                    .contentTransition(.numericText(countsDown: true))
            } minimal: {
                Image(systemName: "dumbbell.fill")
                    .font(.callout.bold())
            }
            .keylineTint(Color.theme.primary)
        }
    }
}
