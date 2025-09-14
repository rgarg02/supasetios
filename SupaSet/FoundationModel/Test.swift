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
struct Template {
    let name: String
    let exercises: [TemplateExerciseGen]
}

@available(iOS 26, *)
@Generable
struct TemplateExerciseGen {
    let name: String
    let notes: String
}
#Playground {
    if #available(iOS 26.0, *) {
        let session = LanguageModelSession()
        let result = try await session.respond(to: "Give me a workout template for a push day", generating: Template.self)
        print(result.content)
    } else {
    }
    
}
