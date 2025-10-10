//
//  NameEditor.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/30/25.
//
import SwiftUI
struct NameEditor: View {
    @Binding var name: String
    var onChange: ((String) -> ())
    @State private var debouncedName: String = ""
    var font: Font = .title
    init(name: Binding<String>, onChange: @escaping (String) -> Void) {
        self._name = name
        self.onChange = onChange
    }
    var body: some View {
        TextField("New Workout", text: $name)
            .multilineTextAlignment(.center)
            .font(font.bold())
            .textFieldStyle(.plain)
            .submitLabel(.done)
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                debouncedName = name
            }
            .onChange(of: debouncedName) { oldValue, newValue in
                if newValue != name {
                    onChange(newValue)
                }
            }
            .animation(.easeOut, value: name)
            .debounced(value: $name, debouncedValue: $debouncedName)
    }
}
