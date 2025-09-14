//
//  ExerciseMappingPage.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//

import SwiftUI

struct ExerciseMappingPage: View {
    let mappings: [ExerciseMapping]
    @State private var mappingOptions: [String: [String]] = [:]
    @State private var chosenOptions: [String: String] = [:]
    @Environment(\.appDatabase) private var appDatabase
    var body: some View {
        VStack(spacing: 15) {
            ForEach(Array(mappingOptions), id: \.key) { key, value in
                // TODO: Add your row content here
                HStack {
                    Text("\(key)")
                    Picker("Option", selection: $chosenOptions[key]) {
                        ForEach(value, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
        }
        .task {
            do {
                for mapping in mappings {
                    var name = mapping.name.lowercased()
                    for equipment in Equipment.allCases {
                        if name.contains(equipment.rawValue) {
                            name = name.replacingOccurrences(of: equipment.rawValue.lowercased(), with: "")
                        }
                    }
                    let option = try await appDatabase.fetchClosestExerciseNames(to: name)
                    mappingOptions[mapping.exerciseId] = option
                    chosenOptions[mapping.exerciseId] = option.first
                }
            }catch {
                // TODO:
            }
        }
    }
}

#Preview {
    ExerciseMappingPage(mappings: [ExerciseMapping(exerciseId: "deadlift", name: "deadlift")])
        .appDatabase(.withStrengthExercises())
}

