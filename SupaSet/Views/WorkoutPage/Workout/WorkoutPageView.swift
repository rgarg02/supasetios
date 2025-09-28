//
//  WorkoutPageView.swift
//  SupaSet
//
//  Created by Rishi Garg on 6/26/25.
//

import SwiftUI
import GRDBQuery
import GRDB
struct WorkoutPageView: View {
    @Environment(\.appDatabase) private var appDatabase
    var body: some View {
        ScrollView{
            VStack {
                TemplateCarasouleView()
            }
        }
    }
}
private struct OngoingWorkoutQuery: ValueObservationQueryable {
    static var defaultValue: WorkoutRecord? { nil }
    
    func fetch(_ db: Database) throws -> WorkoutRecord? {
        try WorkoutRecord.filter{$0.endDate == nil}.fetchOne(db)
    }
}
private struct WorkoutTemplatesQuery: ValueObservationQueryable {
    static var defaultValue: [WorkoutTemplate] { [] }
    
    func fetch(_ db: Database) throws -> [WorkoutTemplate] {
        try WorkoutTemplate
            .fetchAll(db)
    }
}
