//
//  TE+E.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/1/25.
//
import SwiftUI
struct TemplateExerciseWithExercise: Decodable, Identifiable {
    var id = UUID()
    var templateExercise: TemplateExercise
    var exercise: Exercise?
}
