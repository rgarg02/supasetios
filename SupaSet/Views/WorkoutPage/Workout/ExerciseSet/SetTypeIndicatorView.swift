//
//  SetTypeIndicatorView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/25/25.
//
import SwiftUI

struct SetTypeIndicatorView: View {
    @State private var expandSetTypeOptions = false
    let exerciseSetType: SetType
    let setOrder: Int
    var onChange: ((SetType) -> ())
    @State private var progress: CGFloat = .zero
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                ExpandableHorizontalGlassContainer(
                    placeAtLeading: true,
                    isInteractive: false,
                    size: .init(width: expandSetTypeOptions ? 70 : 40, height: 40),
                    progress: progress
                ) {
                    ForEach(SetType.allCases.sorted(by: {$0.rawValue > $1.rawValue}).filter({$0 != exerciseSetType}), id: \.self){ setType in
                        Button {
                            onChange(setType)
                            expandSetTypeOptions = false
                            withAnimation(.bouncy(duration: 0.7, extraBounce: 0.07)) {
                                progress = progress == 0 ? 1 : 0
                                
                            }
                        } label: {
                            VStack(spacing: 0) {
                                Text(setType.displayText(order: setOrder))
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(setType.color)
                                Text(setType.description)
                                    .font(.footnote)
                                    .foregroundStyle(.primary)
                                    .foregroundStyle(setType.color)
                            }
                        }
                        .buttonStyle(.plain)
                        .containerValue(\.unionID, "OPTIONS")
                    }
                } label: {
                    Button {
                        expandSetTypeOptions.toggle()
                        withAnimation(.bouncy(duration: 0.7, extraBounce: 0)) {
                            progress = progress == 0 ? 1 : 0
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Text(exerciseSetType.displayText(order: setOrder))
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(exerciseSetType.color)
                            if expandSetTypeOptions {
                                Text(exerciseSetType.description)
                                    .font(.footnote)
                                    .foregroundStyle(.primary)
                                    .foregroundStyle(exerciseSetType.color)
                                    .transition(.opacity.combined(with: .blurReplace))
                            }
                        }
                        
                    }
                }
                .animation(.default, value: expandSetTypeOptions)
            } else {
                HStack {
                    Button{
                        withAnimation(.bouncy(duration: 0.7, extraBounce: 0)) {
                            expandSetTypeOptions.toggle()
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Text(exerciseSetType.displayText(order: setOrder))
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(exerciseSetType.color)
                            if expandSetTypeOptions {
                                Text(exerciseSetType.description)
                                    .font(.footnote)
                                    .foregroundStyle(.primary)
                                    .foregroundStyle(exerciseSetType.color)
                                    .transition(.opacity.combined(with: .blurReplace))
                            }
                        }
                        .frame(width: expandSetTypeOptions ? 70: 40, height: 40)
                    }
                    .background(.regularMaterial, in: .capsule)
                    .buttonStyle(.borderless)
                    if expandSetTypeOptions {
                        ForEach(SetType.allCases.sorted(by: {$0.rawValue > $1.rawValue}).filter({$0 != exerciseSetType}), id: \.self){ setType in
                            Button {
                                onChange(setType)
                                withAnimation(.bouncy(duration: 0.7, extraBounce: 0)) {
                                    expandSetTypeOptions.toggle()
                                }
                            } label: {
                                VStack(spacing: 0) {
                                    Text(setType.displayText(order: setOrder))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(setType.color)
                                    Text(setType.description)
                                        .font(.footnote)
                                        .foregroundStyle(.primary)
                                        .foregroundStyle(setType.color)
                                }
                                .frame(width: expandSetTypeOptions ? 70: 40, height: 40)
                                .background(.regularMaterial, in: .capsule)
                                
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    SetTypeIndicatorView(exerciseSetType: .drop, setOrder: 0, onChange: { _ in
        
    })
}
