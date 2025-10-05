//
//  GlassButtonStyle.swift
//  SupaSet
//
//  Created by Rishi Garg on 10/4/25.
//


import SwiftUI

// MARK: - Glass Button Style Modifier
struct GlassButtonStyle: ViewModifier {
    var tintColor: Color?
    var cornerRadius: CGFloat?
    func body(content: Content) -> some View {
        content
            .modify { view in
                if #available(iOS 26, *) {
                    view
                        .glassEffect(.regular.interactive().tint(tintColor), in: cornerRadius == nil ? .buttonBorder : .roundedRectangle(radius: cornerRadius!))
                } else {
                    view
                        .background(tintColor == nil ? .bgLight : tintColor!, in: cornerRadius == nil ? .buttonBorder : .roundedRectangle(radius: cornerRadius!))
                }
            }
    }
}
extension View {
    /// Applies a glass effect button style with customizable parameters
    /// - Parameters:
    ///   - tintColor: The tint color for the glass effect (default: .theme.primary)
    ///   - cornerRadius: The corner radius of the button (default: 12)
    ///   - opacity: The opacity of the tint color (default: 0.6)
    /// - Returns: A view with the glass button style applied
    func glassButtonStyle(
        tintColor: Color = .theme.primary,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        modifier(GlassButtonStyle(tintColor: tintColor, cornerRadius: cornerRadius))
    }
}
