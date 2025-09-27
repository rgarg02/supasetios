//
//  CustomMenu.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/22/25.
//
import SwiftUI

struct CustomMenuView<Label: View, Content: View>: View {
    var style: CustomMenuStyle = .bordered
    var isHapticsEnabled = true
    @ViewBuilder var label: Label
    @ViewBuilder var content: Content
    
    @State private var isExpanded = false
    @State private var haptics = false
    
    @Namespace private var namespace
    var body: some View {
        Button {
            if isHapticsEnabled {
                haptics.toggle()
            }
            isExpanded.toggle()
        } label: {
            label
                .matchedTransitionSource(id: "CONTENT", in: namespace)
        }
        .applyStyle(style)
        .sensoryFeedback(.selection, trigger: haptics)
        .popover(isPresented: $isExpanded, attachmentAnchor: .point(.bottomTrailing)) {
            PopOverHelper {
                content
            }
            .navigationTransition(.zoom(sourceID: "CONTENT", in: namespace))
        }
    }
}

fileprivate struct PopOverHelper<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var isVisible = false
    
    var body: some View {
        content
            .opacity(isVisible ? 1: 0)
            .task {
                try? await Task.sleep(for: .seconds(0.1))
                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                    isVisible = true
                }
            }
            .presentationCompactAdaptation(.popover)
    }
}
enum CustomMenuStyle: String, CaseIterable {
    case bordered = "Bordered"
    case prominent = "Prominent"
}

fileprivate extension View {
    @ViewBuilder
    func applyStyle(_ style: CustomMenuStyle) -> some View {
        switch style {
        case .bordered:
            if #available(iOS 26.0, *) {
                self.buttonStyle(.glass)
            } else {
                self.buttonStyle(.bordered) // fallback
            }
        case .prominent:
            if #available(iOS 26.0, *) {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.borderedProminent) // fallback
            }
        }
    }
}

#Preview {
    @Previewable @State var showOptions = false
    ScrollView {
        VStack(spacing: 25) {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: [.red,.blue,.purple,.brown], startPoint: .top, endPoint: .bottom))
                .frame(height: 220)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("History")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // ... inside #Preview
                CustomMenuView(style: .bordered, isHapticsEnabled: true) {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .frame(width: 40, height: 40)
                } content: {
                    // --- MODIFICATION START ---
                    if showOptions {
                        Button("back") {
                            showOptions = false
                        }
                        // This is your destination view
                        RoundedRectangle(cornerRadius: 30)
                            .fill(LinearGradient(colors: [.red,.blue,.purple,.brown], startPoint: .top, endPoint: .bottom))
                            .frame(width: 300, height: 200)
                            .transition(.scale.combined(with: .opacity)) // Add a nice transition
                    } else {
                        // This is your original list of options
                        VStack {
                            
                            HStack {
                                Image(systemName: "circle")
                                Text("Option 1")
                            }
                            .frame(maxWidth: .infinity)
                            .fontWeight(.medium)
                            .padding(.bottom)

                            HStack {
                                Image(systemName: "circle")
                                Text("Option 2")
                            }
                            .onTapGesture {
                                withAnimation {
                                    // Just toggle the state
                                    showOptions = true
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .fontWeight(.medium)
                            .padding(.bottom)
                            
                            // ... Other options
                        }
                        .padding()
                    }
                    // --- MODIFICATION END ---
                }
                
            }
        }
        .padding(15)
        .padding(.bottom, 700)
    }
}
