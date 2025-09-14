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
    let name: String
    @State private var xOffset = 0.0
    var body: some View {
        Text("\(name)")
            .font(.title2.bold())
            .lineLimit(1)
    }
}
