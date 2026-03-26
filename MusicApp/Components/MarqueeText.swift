struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double

    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            let textSize = text.size(using: font)

            Text(text)
                .font(font)
                .offset(x: animate ? -textSize.width - geo.size.width : 0)
                .animation(
                    Animation.linear(duration: (textSize.width + geo.size.width) / speed)
                        .repeatForever(autoreverses: false),
                    value: animate
                )
                .onAppear {
                    if textSize.width > geo.size.width {
                        animate = true
                    }
                }
        }
        .clipped()
    }
}
