//
//  NameEditor.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//
import SwiftUI
struct NameEditor: View {
    let name: String
    var onChange: ((String) -> ())
    @State private var editableName: String = ""
    @State private var debouncedName: String = ""
    var font: Font = .title
    var body: some View {
        TextField("New Workout", text: $editableName)
            .multilineTextAlignment(.center)
            .font(font.bold())
            .textFieldStyle(.plain)
            .submitLabel(.done)
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                editableName = name
                debouncedName = name
            }
            .onChange(of: debouncedName) { oldValue, newValue in
                if newValue != name {
                    onChange(newValue)
                }
            }
            .debounced(value: $editableName, debouncedValue: $debouncedName)
    }
}
