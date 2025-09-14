//
//  OsCheck.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//
import SwiftUI
extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}
