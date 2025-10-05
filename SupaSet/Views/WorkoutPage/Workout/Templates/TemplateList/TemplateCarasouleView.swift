//
//  TemplateCardView.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/2/25.
//

import SwiftUI
import GRDBQuery

struct TemplateCarasouleView: View {
    @Query(TemplateRequest())
    private var templates: [WorkoutTemplate]
    @Environment(\.appDatabase) private var appDatabase
    @Namespace var namespace
    var body: some View {
        VStack {
            TemplateCaraouselTopControls()
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(templates) {template in
                    NavigationLink {
                        EditTemplateView(appDatabase: appDatabase, workoutTemplate: template)
                            .navigationTransition(.zoom(sourceID: template.id, in: namespace))
                    } label: {
                        TemplateCardView(template: template)
                            .matchedTransitionSource(id: template.id, in: namespace)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    @ViewBuilder
    func TemplateCaraouselTopControls() -> some View {
        HStack{
            Text("Templates")
                .font(.title.bold())
                .foregroundStyle(Color.theme.text)
            Spacer()
            NavigationLink {
                EditTemplateView(appDatabase: appDatabase)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.caption.bold())
                        .foregroundStyle(Color.theme.text_muted)
                    Text("New Template")
                        .font(.caption.bold())
                        .foregroundStyle(Color.primary)
                        .foregroundStyle(Color.theme.text)
                }
                .padding(5)
                .background(
                    ZStack{
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.theme.bg)
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.theme.border, lineWidth: 1)
                    }
                )
            }
            .contentShape(.rect)
            .buttonStyle(.plain)
        }
        .padding(.bottom, 16)
    }
}
struct TemplateCardView: View {
    let template: WorkoutTemplate
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(template.name)
                .lineLimit(1)
                .font(.headline)
                .foregroundStyle(Color.primary)
                .padding(.vertical, 3)
            if let creationDate = template.creationDate {
                Text(creationDate.formatted())
                    .font(.caption2)
                    .foregroundStyle(Color.theme.text_muted)
                    .padding(.bottom, 3)
            }
            TemplateExerciseCardView(templateId: template.id)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .leading)
        .padding(8)
        .cornerRadius(24)
        .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [.bgLight, .bg, .bg], startPoint: .top, endPoint: .bottom))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(LinearGradient(colors: [.highlight, .border], startPoint: .top, endPoint: .bottom), lineWidth: 1)
        }
    }
}

struct TemplateExerciseCardView: View {
    @Query<TemplateExerciseRequest>
    private var exerciseNameWithCount: [ExerciseNameWithCount]
    let templateId: Int64?
    init(templateId: Int64?) {
        _exerciseNameWithCount = Query(TemplateExerciseRequest(templateId: templateId))
        self.templateId = templateId
    }
    var body: some View {
        ForEach(exerciseNameWithCount.prefix(4)) { pair in
            HStack {
                Text("\(pair.count)x")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(Color.theme.secondary)
                Text(pair.name)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(Color.theme.text)
            }
        }
        if exerciseNameWithCount.count > 4 {
            Text("+ \(exerciseNameWithCount.count - 4) more")
                .font(.caption)
                .foregroundStyle(Color.theme.text_muted)
        }
        Spacer()
        StartNewWorkoutButton(templateId: templateId)
    }
}

struct StartNewWorkoutButton: View {
    @Environment(\.appDatabase) private var appDatabase
    let templateId: Int64?
    var body: some View {
        Button {
            if let templateId {
                Task {
                    do {
                        try await appDatabase.startWorkout(from: templateId)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                // Add an icon similar to the trophy in the image
                Image(systemName: "figure.run")
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.leading)
                    .foregroundStyle(Color.theme.primary)
                Text("Start Workout")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.theme.primary)
                
                Spacer()
            }
            .padding(5)
        }
        .cornerRadius(16)
        .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.bgLight)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.border, lineWidth: 1)
        }
        .buttonStyle(.plain)
    }
}
    #Preview {
        NavigationStack {
            TemplateCarasouleView()
        }
        .appDatabase(.withTemplates())
    }
