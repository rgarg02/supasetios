//
//  ProfilePageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//
import SwiftUI

struct ProfilePageView: View {
    @State private var showSettings = false
    @Environment(\.appDatabase) private var appDatabase
    var body: some View {
        ScrollView {
            
        }
        .frame(maxHeight: .infinity)
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings", systemImage: "gear") {
                    showSettings = true
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsPage(appDatabase: appDatabase)
        }
    }
}

#Preview {
    NavigationStack {
        ProfilePageView()
            .navigationTitle("Profile")
    }
}
