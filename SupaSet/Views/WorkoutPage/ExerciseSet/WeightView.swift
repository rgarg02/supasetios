//
//  WeightView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/25/25.
//

import SwiftUI
struct WeightView: View {
    let weight: Double
    let isDone: Bool
    var onChange: ((Double) -> ())
    @State private var editableWeight: Double?
    @State private var debouncedWeight: Double?
    let fieldType: FieldType
    
    @FocusState var focusedField: FieldType?
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        return formatter
    }()
    
    init(weight: Double, isDone: Bool, fieldType: FieldType, onChange: @escaping (Double) -> ()) {
        self.weight = weight
        self.isDone = isDone
        self.onChange = onChange
        self.fieldType = fieldType
        editableWeight = isDone ? weight : nil
        debouncedWeight = isDone ? weight : nil
    }
    
    @Environment(ToolbarVC.self) private var toolbarVC
    
    var body: some View {
        TextField(String(format: "%g", weight), value: $editableWeight, formatter: formatter)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .focused($focusedField, equals: fieldType)
            .debounced(value: $editableWeight, debouncedValue: $debouncedWeight)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.regularMaterial)
                    .stroke(toolbarVC.fieldType == fieldType ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
            }
            .onChange(of: debouncedWeight) { _, newValue in
                onChange(debouncedWeight ?? weight)
            }
            .onChange(of: isDone) { oldValue, newValue in
                if newValue {
                    editableWeight = editableWeight == nil ? self.weight : editableWeight
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
            }
    }
}
