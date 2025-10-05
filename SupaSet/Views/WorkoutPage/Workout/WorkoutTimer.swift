//
//  WorkoutTimer.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/18/25.
//

import SwiftUI
internal import Combine
struct WorkoutTimer: View {
    let date: Date
    let endDate: Date?
    @State private var currentTime = Date()
    init(date: Date, endDate: Date? = nil) {
        self.date = date
        self.endDate = endDate
    }
    var timeInterval: TimeInterval {
        if let endDate {
            abs(date.timeIntervalSince(endDate))
        }else{
            abs(date.timeIntervalSince(currentTime))
        }
    }
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
    
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                Text(formattedTime)
                    .monospacedDigit()
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .contentTransition(.numericText(countsDown: true))
                    .glassEffect(endDate == nil ? .clear : .clear.tint(.theme.primary), in: .capsule)
            }else{
                    // Timer Display
                Text(formattedTime)
                    .monospacedDigit()
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background {
                        ZStack{
                            if endDate != nil {
                                Capsule()
                                    .fill(Color.theme.primary.opacity(0.25))
                            }
                            Capsule()
                                .fill(.thinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                    .contentTransition(.numericText(countsDown: true))
            }
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}
