//
//  TemplateNameEditor.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/1/25.
//

//
//  WorkoutNameEditor.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/20/25.
//

import SwiftUI

struct TemplateNameEditor: View {
    let templateName: String
    var onChange: ((String) -> ())
    @State private var templateNameEditable: String = ""
    @State private var debouncedName: String = ""
    var font: Font = .title
    var body: some View {
        TextField("New Workout", text: $templateNameEditable)
            .multilineTextAlignment(.center)
            .font(font.bold())
            .textFieldStyle(.plain)
            .submitLabel(.done)
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                templateNameEditable = templateName
                debouncedName = templateName
            }
            .onChange(of: debouncedName) { oldValue, newValue in
                if newValue != templateName {
                    onChange(newValue)
                }
            }
            .debounced(value: $templateNameEditable, debouncedValue: $debouncedName)
    }
}
