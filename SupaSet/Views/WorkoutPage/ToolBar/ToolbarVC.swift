//
//  ToolbarVC.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/31/25.
//

import SwiftUI
enum FieldType: Hashable {
    case weight(Int, Int) // Exercise set ID
    case reps(Int, Int, Int = 0)   // Exercise set ID
    case workoutNotes
    var sortKeys: (Int, Int, Int, Int) {
            switch self {
            // workoutNotes is always first (exerciseOrder: -1)
            case .workoutNotes:
                return (-1, -1, -1, -1)
            // Weight fields come before Reps fields (typeOrder: 0)
            case .weight(let exerciseOrder, let setOrder):
                return (exerciseOrder, setOrder, 0, 0)
            // Reps fields come after Weight fields (typeOrder: 1)
            case .reps(let exerciseOrder, let setOrder, let upperLimit):
                return (exerciseOrder, setOrder, 1, upperLimit)
            }
        }
}
@Observable
final class ToolbarVC {
    var fieldType: FieldType?
    @ObservationIgnored var allFields: Set<FieldType> = []
    @ObservationIgnored var sortedField: [FieldType] {
        allFields.sorted {$0.sortKeys < $1.sortKeys}
    }
    func moveToNextField() {
            guard let currentField = fieldType else { return }

            // Find the position of the current field in the sorted list.
            guard let currentIndex = sortedField.firstIndex(of: currentField) else {
                return
            }

            // Move to the next field if it exists.
            if currentIndex + 1 < sortedField.count {
                fieldType = sortedField[currentIndex + 1]
            }
        }
    func moveToPreviousField() {
        guard let currentField = fieldType else { return }
        
        // Find the position of the current field in the sorted list.
        guard let currentIndex = sortedField.firstIndex(of: currentField) else {
            return
        }
        
        // Move to the previous field if it exists.
        if currentIndex > 0 {
            fieldType = sortedField[currentIndex - 1]
        }
    }
}
