import SwiftUI

struct ScrollViewTest: View {
    @State private var showOptions = false
    let viewID = "CONTENTID"
    let optionsID = "OPTIONID"
    @Namespace var namespace
    let spacing : CGFloat = 5
    @State private var progress: CGFloat = 0
    @State private var isUnion: Bool = false
    @State private var showText: Bool = false
    var body: some View {
        // The horizontal ScrollView allows the content to expand beyond the screen's width.
        if #available(iOS 26, *) {
            ScrollViewReader {proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ExpandableHorizontalGlassContainer(
                            placeAtLeading: true,
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
                                Image(systemName: "ellipsis")
                            }
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.8, extraBounce: 0.07)) {
                                    progress = progress == 0 ? 1 : 0
                                }
                            }
                            .font(showText ? .body : .title3)
                            .fontWeight(showText ? .regular : .semibold)
                        }
                        .font(.title3)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(.white)
                        HStack(spacing: spacing) {
                            Capsule()
                                .frame(height: 30)
                                .frame(maxWidth: .infinity)
                            Capsule()
                                .frame(height: 30)
                                .frame(maxWidth: .infinity)
                            Capsule()
                                .frame(height: 30)
                                .frame(maxWidth: .infinity)
                            Circle()
                                .frame(width: 30)
                        }
                        .background(.white)
                        .frame(width: UIScreen.main.bounds.size.width - 30 - spacing)
                    }
                }
            }
            .background(.white)
            .animation(.bouncy, value: showOptions)
        }
    }
}

#Preview {
    ScrollViewTest()
        .background(.white)
}
