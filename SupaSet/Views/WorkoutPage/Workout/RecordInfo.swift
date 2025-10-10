//
//  WorkoutRecordInfo.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//

import SwiftUI
struct RecordInfo: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(ToolbarVC.self) private var toolbarVC
    let creationDate: Date
    let endDate: Date? 
    let modificationDate: Date
    let showTimer: Bool
    @Binding var notes: String
    var onChange: ((String) -> ())
    @State private var debouncedNotes: String = ""
    @FocusState private var isFocused: FieldType?
    let fieldType = FieldType.workoutNotes
    var font: Font = .body
    
    init(creationDate: Date, endDate: Date? = nil, modificationDate: Date, showTimer: Bool = true, notes: Binding<String>, onChange: @escaping (String) -> Void) {
        self.showTimer = showTimer
        self.creationDate = creationDate
        self.endDate = endDate
        self.modificationDate = modificationDate
        self._notes = notes
        self.onChange = onChange
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                    Text(creationDate.formatted())
                        .frame(alignment: .leading)
                }
                if showTimer {
                    WorkoutTimer(date: creationDate, endDate: endDate)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if endDate != nil {
                HStack {
                    Text("Modified at:")
                    Text(modificationDate.formatted())
                        .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $notes)
                    .multilineTextAlignment(.leading)
                    .font(font)
                    .padding()
                    .textFieldStyle(.plain)
                    .focused($isFocused, equals: fieldType)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.regularMaterial)
                            .stroke(toolbarVC.fieldType == fieldType ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
                    }
                    .textEditorStyle(.plain)
                if notes.isEmpty {
                    Text("Add your notes here")
                        .font(font)
                        .padding(EdgeInsets(top: 7, leading: 4, bottom: 0, trailing: 0))
                        .foregroundStyle(.placeholder)
                        .padding()
                }
            }
        }
        .animation(.easeOut, value: notes)
        .padding()
        .onAppear {
            debouncedNotes = notes
        }
        .debounced(value: $notes, debouncedValue: $debouncedNotes)
        .onChange(of: debouncedNotes) { oldValue, newValue in
            if newValue != notes {
                onChange(newValue)
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
