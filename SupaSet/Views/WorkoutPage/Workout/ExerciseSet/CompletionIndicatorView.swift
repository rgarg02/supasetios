//
//  CompletionIndicatorView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/25/25.
//

import SwiftUI
struct CompletionIndicatorView: View {
    let isDone: Bool
    var onTap: (() -> ())
    var body: some View {
        Button {
            onTap()
        } label: {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isDone ? .success : .gray.opacity(0.8))
        }
        .contentTransition(.symbolEffect(.replace, options: .speed(2)))
        .buttonStyle(.borderless)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.1), value: isDone)
    }
}
