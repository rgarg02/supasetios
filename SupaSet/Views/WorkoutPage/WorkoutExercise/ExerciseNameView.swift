//
//  ExerciseNameView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/21/25.
//

import SwiftUI
import GRDBQuery
import GRDB
struct ExerciseNameView: View {
    @Query<ExerciseNameRequest>
    private var name: String
    init(exerciseId: String) {
        self._name = Query(ExerciseNameRequest(exerciseId: exerciseId))
    }
    var body: some View {
        Text("\(name)")
            .font(.title2.bold())
            .lineLimit(1)
    }
}

struct ExerciseNameRequest: ValueObservationQueryable {
    /// How players are sorted.
    var exerciseId: String

    static var defaultValue: String { "" }

    func fetch(_ db: Database) throws -> String {
        let exercise = try Exercise
            .filter({$0.id == exerciseId})
            .fetchOne(db)
        return exercise?.name ?? ""
    }
}
