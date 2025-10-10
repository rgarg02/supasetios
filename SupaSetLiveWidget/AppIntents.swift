//
//  CompleteSetIntent.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//
import AppIntents
import WidgetKit
import ActivityKit

struct IncreaseWeightIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Increase Weight"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false
    func perform() async throws -> some IntentResult {
        await WorkoutActivityManager.shared.increaseWeight()
        return .result()
    }
}
struct DecreaseWeightIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Decrease Weight"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false
    func perform() async throws -> some IntentResult {
        await WorkoutActivityManager.shared.decreaseWeight()
        return .result()
    }
}
struct DecreaseRepsIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Decrease Reps"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false
    func perform() async throws -> some IntentResult {
        await WorkoutActivityManager.shared.decreaseReps()
        return .result()
    }
}
struct IncreaseRepsIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Increase Reps"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false
    func perform() async throws -> some IntentResult {
        await WorkoutActivityManager.shared.increaseReps()
        return .result()
    }
}
struct CompleteSetIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Complete Set"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false
    func perform() async throws -> some IntentResult {
        await WorkoutActivityManager.shared.completeSet()
        return .result()
    }
}
