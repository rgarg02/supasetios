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

struct RecordInfo: View {
    let creationDate: Date?
    let modificationDate: Date?
    let notes: String
    let showTimer: Bool
    var updateNotes: ((String) -> ())
    @State private var editableNotes: String = ""
    @State private var debouncedNotes: String = ""
    @FocusState private var isFocused: FieldType?
    let fieldType = FieldType.workoutNotes
    var font: Font = .body
    @Environment(ToolbarVC.self) private var toolbarVC
    var body: some View {
        VStack(spacing: 20) {
            if let creationDate, let modificationDate {
                HStack(spacing: 15) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                        Text(creationDate.formatted())
                            .frame(alignment: .leading)
                    }
                    if showTimer {
                        WorkoutTimer(date: creationDate)
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
                TextEditor(text: $editableNotes)
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
                if editableNotes.isEmpty {
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
            editableNotes = notes
            debouncedNotes = notes
        }
        .debounced(value: $editableNotes, debouncedValue: $debouncedNotes)
        .onChange(of: debouncedNotes) { oldValue, newValue in
            if newValue != notes {
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
