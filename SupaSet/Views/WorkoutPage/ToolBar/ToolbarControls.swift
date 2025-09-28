//
//  ToolBarControls.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/22/25.
//

import SwiftUI

struct ToolbarControls: View {
    @Bindable var toolbarVC: ToolbarVC
    var body: some View {
        HStack {
            Spacer()
            if toolbarVC.fieldType != nil {
                Button {
                    toolbarVC.moveToNextField()
                } label: {
                    Image(systemName: "arrowshape.right.fill")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.primary)
            }
        }
        .padding(10)
        .containerShape(.capsule)
        .modify({ view in
            if #available(iOS 26, *){
                view
                    .background(.bg.opacity(0.01))
                    .glassEffect(.regular.interactive(),in: .capsule)
            } else {
                view
                    .background(.thinMaterial, in: .capsule)
            }
        })
        .padding(.horizontal)
        .transition(.blurReplace)
    }
}

#Preview {
    @Previewable @State var toolbarVC = ToolbarVC()
    ZStack {
        Rectangle()
            .fill(.red.gradient)
        ToolbarControls(toolbarVC: toolbarVC)
            .onAppear {
                toolbarVC.fieldType = .reps(0, 0, 0)
            }
    }
}
