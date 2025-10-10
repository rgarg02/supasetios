//
//  Test.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/3/25.
//

import Playgrounds
import FoundationModels
@available(iOS 26, *)
@Generable
struct TemplateSetGen {
    @Generable
    enum RepType{
        case reps(Int)
        case range(Int, Int)
    }
    @Generable
    enum SetType: String {
        case working, warmup, drop, failure
    }
    let repType: RepType
    @Guide(description: "Weight for the set in KGs")
    let weight: Double
    @Guide(description: "Any notes regarding how to perform the set if the user asks")
    let notes: String?
    let setType: SetType
    
}
@available(iOS 26, *)
@Generable
struct TemplateExerciseGen{
    let exerciseID: String
    let templateSets: [TemplateSetGen]
}
@available(iOS 26, *)
@Generable
struct TemplateGen {
    let name: String
    let notes: String
    let templateExercises: [TemplateExerciseGen]
}
