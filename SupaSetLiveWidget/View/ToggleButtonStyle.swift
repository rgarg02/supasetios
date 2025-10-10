//
//  ToggleButtonStylr.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/8/25.
//
import SwiftUI

struct ToggleButtonStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Complete Set")
                }
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity)
            }
        }
        .allowsHitTesting(!configuration.isOn)
        .padding(5)
        .buttonStyle(PlainButtonStyle())
        .background(configuration.isOn ? Color.theme.success : Color.theme.secondary)
        .clipShape(.capsule)
    }
}
