//
//  PlaceholderSetView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/28/25.
//

import SwiftUI

struct PlaceholderSetView: View {
    var onTap: (() -> Void)
    var body: some View {
        Button(action: onTap) {
            Text("Add Set")
                .font(.callout.bold())
                .frame(maxWidth: .infinity)
                .padding(7)
        }
        .contentShape(.rect)
        .foregroundStyle(.primary)
        .modify {
            if #available(iOS 26, *) {
                $0
                    .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 12))
                
            }else {
                $0
                    .background(.regularMaterial)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    PlaceholderSetView(onTap: {
        print("tapped")
    })
}
