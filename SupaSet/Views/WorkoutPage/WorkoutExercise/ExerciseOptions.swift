//
//  ExerciseOptions.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/30/25.
//

import SwiftUI


struct ExerciseOptions: View {
    @State private var changeExercise = false
    @Environment(\.appDatabase) private var appDatabase
    var onDelete: (() -> Void)
    var replaceExercise: ((String?) -> Void)
    @Namespace var namespace
    var body: some View {
        Menu {
            Button {
                changeExercise = true
            } label: {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Replace Execise")
                }
            }
            Button (role: .destructive){
                onDelete()
                
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Exercise")
                }
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 40, height: 40)
        }
        .foregroundStyle(.primary)
        .menuStyle(.button)
        .matchedTransitionSource(id: "MENU", in: namespace)
        .navigationDestination(isPresented: $changeExercise) {
            ExerciseListView(appDatabase: appDatabase, onAdd: { exercises in
                replaceExercise(exercises.first)
            }, selectingMultiple: false)
            .navigationTransition(.zoom(sourceID: "MENU", in: namespace))
        }
    }
}

#Preview {
    NavigationStack {
        VStack{
            ExerciseOptions {
                
            } replaceExercise: { exerciseId in
                
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .appDatabase(.withTemplates())
}
