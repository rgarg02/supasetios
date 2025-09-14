//
//  Color.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/4/25.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let bg = Color("bg")
    let bg_dark = Color("bg-dark")
    let bg_light = Color("bg-light")
    
    
    let text = Color("text")
    let text_muted = Color("text-muted")
    
    
    let highlight = Color("highlight")
    let border = Color("border")
    let border_muted = Color("border-muted")
    
    
    let primary = Color("primary")
    let secondary = Color("secondary")
    
    let danger = Color("danger")
    let warning = Color("warning")
    let success = Color("success")
    let info = Color("info")
}
