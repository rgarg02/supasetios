//
//  WorkoutRecordInfo.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/1/25.
//


//
//  WorkoutRecordInfo.swift
//  SupaSet
//
//  Created by Rishi Garg on 7/10/25.
//

import SwiftUI

struct TemplateRecordInfo: View {
    let template: WorkoutTemplate
    var updateNotes: ((String) -> ())
    
    @State private var templateNotes: String = ""
    @State private var debouncedNotes: String = ""
    @FocusState private var isFocused: FieldType?
    let fieldType = FieldType.workoutNotes
    var font: Font = .body
    @Environment(ToolbarVC.self) private var toolbarVC
    var body: some View {
        VStack(spacing: 20) {
            if let creationDate = template.creationDate, let modificationDate = template.modificationDate {
                HStack(spacing: 15) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                        Text(creationDate.formatted())
                            .frame(alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Modified at:")
                    Text(modificationDate.formatted())
                        .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $templateNotes)
                    .multilineTextAlignment(.leading)
                    .font(font)
                    .padding()
                    .textFieldStyle(.plain)
                    .focused($isFocused, equals: fieldType)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.regularMaterial)
                    }
                    .textEditorStyle(.plain)
                if templateNotes.isEmpty {
                    Text("Add your notes here")
                        .font(font)
                        .padding(EdgeInsets(top: 7, leading: 4, bottom: 0, trailing: 0))
                        .foregroundStyle(.placeholder)
                        .padding()
                }
            }
        }
        .padding()
        .onAppear {
            templateNotes = template.notes
            debouncedNotes = template.notes
        }
        .debounced(value: $templateNotes, debouncedValue: $debouncedNotes)
        .onChange(of: debouncedNotes) { oldValue, newValue in
            if newValue != template.notes {
                updateNotes(newValue)
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if let newValue {
                toolbarVC.fieldType = newValue
            }
        }
        .onChange(of: toolbarVC.fieldType) { _, newValue in
            if let newValue, newValue == fieldType {
                isFocused = fieldType
            }
        }
        .onAppear {
            toolbarVC.allFields.insert(fieldType)
        }
    }
}

#Preview {
    let workout = WorkoutRecord(id: 1, name: "New Workout", notes: "")
    WorkoutRecordInfo(workout: workout)
        .appDatabase(.workoutWithPopulatedExercise(workoutId: 1))
}
