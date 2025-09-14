//
//  RepsView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/25/25.
//

import SwiftUI
struct RepsView: View {
    let reps: Int
    let isDone: Bool
    var onChange: ((Int) -> ())
    @State private var editableReps: Int?
    @State private var debouncedReps: Int?
    let fieldType: FieldType
    @FocusState var focusedField: FieldType?
    init(reps: Int, isDone: Bool, fieldType: FieldType, onChange: @escaping (Int) -> ()) {
        self.reps = reps
        self.isDone = isDone
        self.onChange = onChange
        self.fieldType = fieldType
        editableReps = isDone ? reps : nil
        debouncedReps = isDone ? reps : nil
    }
    @Environment(ToolbarVC.self) private var toolbarVC
    @State private var canBackspaceBackwards: Bool = false
    var body: some View {
        TextField(String(reps), value: $editableReps, format: .number)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .focused($focusedField, equals: fieldType)
            .debounced(value: $editableReps, debouncedValue: $debouncedReps)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.regularMaterial)
                    .stroke(toolbarVC.fieldType == fieldType ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
            }
            .onChange(of: debouncedReps) { _, newValue in
                onChange(debouncedReps ?? reps)
            }
            .onChange(of: isDone) { oldValue, newValue in
                if newValue {
                    editableReps = editableReps == nil ? self.reps : editableReps
                }
            }
            .onChange(of: focusedField) { oldValue, newValue in
                if let newValue {
                    toolbarVC.fieldType = newValue
                }
            }
            .onChange(of: toolbarVC.fieldType) { _, newValue in
                if let newValue, newValue == fieldType {
                    focusedField = fieldType
                }
            }
            .onAppear {
                toolbarVC.allFields.insert(fieldType)
                canBackspaceBackwards = editableReps == nil
            }
            .onKeyPress(.delete) {
                if canBackspaceBackwards {
                    toolbarVC.moveToPreviousField()
                }
                return .handled
            }

    }
}
