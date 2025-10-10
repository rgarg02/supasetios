//
//  TimerText.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//


// Shared/TimerText.swift

import SwiftUI

struct TimerText: View {
    let startTime: Date
    let alignment: HorizontalAlignment

    var body: some View {
        Text("00:00:00") // Placeholder for layout
            .hidden()
            .overlay(alignment: alignment.toAlignment()) {
                Text(startTime, style: .timer)
                    .multilineTextAlignment(alignment.toTextAlignment())
            }
    }
}

// Helper extensions for alignment conversion
fileprivate extension HorizontalAlignment {
    func toAlignment() -> Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .center
        }
    }

    func toTextAlignment() -> TextAlignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .center
        }
    }
}