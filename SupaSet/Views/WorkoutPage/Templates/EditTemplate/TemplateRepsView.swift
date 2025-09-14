//
//  Untitled.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/1/25.
//

import SwiftUI

struct TemplateRepsView: View {
    let reps: Int
    let repType: TemplateExerciseSet.RepType
    var onChange: ((Int) -> ())
    @State private var editableReps: Int?
    @State private var debouncedReps: Int?
    let fieldType: FieldType
    
    @FocusState var focusedField: FieldType?
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    init(reps: Int? = nil, repType: TemplateExerciseSet.RepType, fieldType: FieldType, onChange: @escaping (Int) -> ()) {
        self.reps = reps ?? 0
        self.repType = repType
        self.onChange = onChange
        self.fieldType = fieldType
        editableReps = reps ?? nil
        debouncedReps = reps ?? nil
    }
    
    @Environment(ToolbarVC.self) private var toolbarVC
    
    var body: some View {
        TextField(String(reps), value: $editableReps, formatter: formatter)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
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
            }
    }
}


#Preview {
    TemplateRepsView(reps: 5, repType: .reps(nil), fieldType: .reps(0, 0)) { _ in
        
    }
    .environment(ToolbarVC())
}
