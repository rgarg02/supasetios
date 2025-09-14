//
//  ContentView.swift
//  SupaSet
//
//  Created by Rishi Garg on 8/26/25.
//


//
//  ContentView.swift
//  GlassMorhpingEffects
//
//  Created by Balaji Venkatesh on 26/07/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct ContentViewGlassMorph: View {
    @State private var progress: CGFloat = 0
    @State private var isUnion: Bool = false
    @State private var showText: Bool = false
    @State private var position: Position = .center
    var body: some View {
        List {
            Section("Preview") {
                ZStack {
                    ExpandableHorizontalGlassContainer(
                        placeAtLeading: position == .leading,
                        size: .init(width: showText ? 70 : 55, height: 55),
                        progress: progress
                    ) {
                        /// Your Custom Action Views!
                        Image(systemName: "suit.heart.fill")
                            .containerValue(\.unionID, isUnion ? "0" : nil)
                            .containerValue(\.contentPadding, showText ? -7.5 : 0)
                        
                        Image(systemName: "square.and.arrow.up.fill")
                            .containerValue(\.unionID, "0")
                            .containerValue(\.contentPadding, showText ? -7.5 : 0)
                    } label: {
                        ZStack {
                            Group {
                                if showText {
                                    Text("Edit")
                                } else {
                                    Image(systemName: "ellipsis")
                                }
                            }
                            .opacity(1 - progress)
                            
                            Group {
                                if showText {
                                    Text("Done")
                                } else {
                                    Image(systemName: "xmark")
                                }
                            }
                            .opacity(progress)
                        }
                        .font(showText ? .body : .title3)
                        .fontWeight(showText ? .regular : .semibold)
                    }
                    .font(.title3)
                    .frame(
                        maxWidth: .infinity,
                        alignment: position == .center ? .center : position == .leading ? .leading : .trailing
                    )
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 22))
            }
            
            Section("Properties") {
                Slider(value: $progress)
                    .padding(.horizontal, 20)
                
                Toggle("Optional Union", isOn: $isUnion)
                
                Toggle("Show Text", isOn: $showText)
                
                Picker("", selection: $position) {
                    ForEach(Position.allCases, id: \.rawValue) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                
                Button("Toggle Actions") {
                    withAnimation(.bouncy(duration: 1, extraBounce: 0.07)) {
                        progress = progress == 0 ? 1 : 0
                    }
                }
                .buttonStyle(.glassProminent)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    enum Position: String, CaseIterable {
        case leading = "Leading"
        case center = "Center"
        case trailing = "trailing"
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ContentViewGlassMorph()
    } else {
        // Fallback on earlier versions
    }
}

@available(iOS 26.0, *)
struct ExpandableHorizontalGlassContainer<Content: View, Label: View>: View, @preconcurrency Animatable {
    var placeAtLeading: Bool = false
    var isInteractive: Bool = true
    var size: CGSize = .init(width: 55, height: 55)
    var progress: CGFloat
    @ViewBuilder var content: Content
    @ViewBuilder var label: Label
    /// View Properties
    @State private var labelPosition: CGRect = .zero
    @Namespace private var animation
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            HStack(spacing: spacing) {
                if placeAtLeading {
                    LabelView()
                }
                
                /// Extracting View using ForEach Subviews and applying glass effect to each individual view!
                ForEach(subviews: content) { subview in
                    let unionID = subview.containerValues.unionID
                    let contentPadding = subview.containerValues.contentPadding
                    let width = size.width + (contentPadding * 2)
                    
                    subview
                        .blur(radius: 12 * scaleProgress)
                        .opacity(opacityProgress)
                        .frame(width: width, height: size.height)
                        /// Optional: Add another property for clear glass effect!
                        .glassEffect(.regular.interactive(isInteractive), in: .capsule)
                        .glassEffectUnion(id: unionID, namespace: animation)
                        /// Disabling interaction until it's expanded!
//                        .allowsHitTesting(progress == 1)
                        .visualEffect { [labelPosition] content, proxy in
                            content
                                .offset(x: offsetX(proxy: proxy, labelPosition: labelPosition))
                        }
                        /// Preserves View Size
                        .fixedSize()
                        .frame(width: max(0, width * progress))
                }
                
                if !placeAtLeading {
                    LabelView()
                }
            }
        }
        .scaleEffect(
            x: 1 + (scaleProgress * 0.35),
            y: 1 - (scaleProgress * 0.4),
            anchor: .center
        )
        .coordinateSpace(.named("CONTAINER"))
        /// CUSTOMIZE VALUES AS PER YOUR NEEDS!
    }
    
    @ViewBuilder
    private func LabelView() -> some View {
        label
            .compositingGroup()
            .blur(radius: 12 * scaleProgress)
            .frame(width: size.width, height: size.height)
            .glassEffect(.regular.interactive(isInteractive), in: .capsule)
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named("CONTAINER"))
            } action: { newValue in
                labelPosition = newValue
            }
            .zIndex(1000)
    }
    
    nonisolated
    func offsetX(proxy: GeometryProxy, labelPosition: CGRect) -> CGFloat {
        let minX = labelPosition.minX - proxy.frame(in: .named("CONTAINER")).minX
        return minX - (minX * progress)
    }
    
    var scaleProgress: CGFloat {
        return progress > 0.5 ? (1 - progress) / 0.5 : (progress / 0.5)
    }
    
    var opacityProgress: CGFloat {
        return (progress - 0.15) / 0.85
    }
    
    var spacing: CGFloat {
        10.0  * progress
    }
}

extension ContainerValues {
    @Entry var unionID: String? = nil
    @Entry var contentPadding: CGFloat = 0
}
