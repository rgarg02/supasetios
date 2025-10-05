//
//  SetType.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import SwiftUI

enum SetType: String, Codable, CaseIterable {
    case warmup
    case working
    case drop
    case failure

    var description: String {
        switch self {
        case .warmup:
            return "Warmup"
        case .working:
            return "Working"
        case .drop:
            return "Drop"
        case .failure:
            return "Failure"
        }
    }

    func displayText(order: Int) -> String {
        switch self {
        case .working:
            return String(order + 1)
        case .warmup:
            return "W"
        case .drop:
            return "D"
        case .failure:
            return "F"
        }
    }
    var color: Color {
        switch self {
        case .failure:
            return .danger  // #FF3B30 : #B71C1C
        case .working:
            return .text  // #34C759 : #2E7D32
        case .warmup:
            return .yellow  // #FF9500 : #E65100
        case .drop:
            return .blue  // #5856D6 : #311B92
        }
    }
}
