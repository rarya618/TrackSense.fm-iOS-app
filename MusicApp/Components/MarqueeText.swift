//
//  MarqueeText.swift
//  MusicApp
//
//  Created by Russal Arya on 3/10/2025.
//

import SwiftUI
import MusicKit

struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double

    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Text(text)
                .font(font)
                .background(
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                textWidth = textGeo.size.width
                                containerWidth = geo.size.width
                                if textWidth > containerWidth {
                                    startScrolling()
                                }
                            }
                    }
                )
                .offset(x: offset)
        }
        .clipped()
    }

    private func startScrolling() {
        let distance = textWidth + containerWidth
        let duration = distance / speed
        offset = 0
        withAnimation(
            Animation.linear(duration: duration)
                .repeatForever(autoreverses: false)
        ) {
            offset = -distance
        }
    }
}

extension String {
    func size(using font: Font) -> CGSize {
        let uiFont: UIFont
        switch font {
        case .largeTitle: uiFont = .preferredFont(forTextStyle: .largeTitle)
        case .title: uiFont = .preferredFont(forTextStyle: .title1)
        case .title2: uiFont = .preferredFont(forTextStyle: .title2)
        case .title3: uiFont = .preferredFont(forTextStyle: .title3)
        case .headline: uiFont = .preferredFont(forTextStyle: .headline)
        case .subheadline: uiFont = .preferredFont(forTextStyle: .subheadline)
        case .body: uiFont = .preferredFont(forTextStyle: .body)
        case .callout: uiFont = .preferredFont(forTextStyle: .callout)
        case .caption: uiFont = .preferredFont(forTextStyle: .caption1)
        case .caption2: uiFont = .preferredFont(forTextStyle: .caption2)
        case .footnote: uiFont = .preferredFont(forTextStyle: .footnote)
        default: uiFont = .systemFont(ofSize: UIFont.systemFontSize)
        }

        let attributes = [NSAttributedString.Key.font: uiFont]
        let size = (self as NSString).size(withAttributes: attributes)
        return size
    }
}
