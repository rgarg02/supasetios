//
//  SettingsPage.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//

import SwiftUI
import UniformTypeIdentifiers
struct SettingsPage: View {
    @State private var isImportingHevy = false
    @State private var csvVm : CsvViewModel
    init(appDatabase: AppDatabase) {
        _csvVm = State(initialValue: CsvViewModel(appDatabase: appDatabase))
    }
    var body: some View {
        Form {
            Section(header: Text("Data Import")) {
                Button("Import from Hevy") {
                    isImportingHevy = true
                }
                Button("Import from Strong") {
                    // TODO: Implement Strong import logic
                    print("Import from Strong tapped")
                }
            }
            if let data = csvVm.hevyData {
                Section {
                    if let mappings = csvVm.exerciseMapping {
                        ExerciseMappingPage(mappings: mappings)
                    }
                } header: {
                    Text("Workout Data")
                }
            }
        }
        .fileImporter(isPresented: $isImportingHevy, allowedContentTypes: [UTType.commaSeparatedText]) { result in
            // Handle selected file result here (placeholder for now)
            csvVm.handleFileImport(for: result)
        }
    }
}

#Preview {
    SettingsPage(appDatabase: .withCardioExercises())
}
