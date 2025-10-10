//
//  ValueControlView.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//


// Controls/ValueControlView.swift

import SwiftUI
import AppIntents

struct ValueControlView: View {
    enum Layout { case vertical, horizontal }

    let label: AnyView
    let value: String
    let decreaseIntent: any AppIntent
    let increaseIntent: any AppIntent
    let layout: Layout

    var body: some View {
        if layout == .vertical {
            verticalLayout
        } else {
            horizontalLayout
        }
    }
    
    // Vertical layout for Dynamic Island
    private var verticalLayout: some View {
        VStack(spacing: 5) {
            label
                .font(.callout.bold())
                .frame(height: 10)

            Text(value)
                .font(.headline.monospacedDigit())
                .frame(width: 65, alignment: .center)
                .padding(.top, 5)

            HStack {
                StepperButton(systemName: "minus", intent: decreaseIntent)
                StepperButton(systemName: "plus", intent: increaseIntent)
            }
        }
        .foregroundStyle(Color.theme.text)
    }
    
    // Horizontal layout for Lock Screen Widget
    private var horizontalLayout: some View {
        HStack(spacing: 2) {
            StepperButton(systemName: "minus", intent: decreaseIntent)
            
            Text(value)
                .font(.headline.monospacedDigit())
                .frame(width: 65, alignment: .center)
            
            StepperButton(systemName: "plus", intent: increaseIntent)
        }
    }
}