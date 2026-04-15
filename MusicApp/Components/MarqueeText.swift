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
    let color: Color
    let tracking: Double
    
    var speed: Double = 30 // points per second
    var delay: Double = 2.0
    
    @State private var containerWidth: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var startTime: Date = .now
    @State private var isAnimating: Bool = false
    
    private var needsScrolling: Bool {
        textWidth > containerWidth
    }
    
    private func currentOffset(at date: Date) -> CGFloat {
        guard needsScrolling && isAnimating else { return 0 }
        let elapsed = date.timeIntervalSince(startTime)
        let totalDistance = textWidth + 40
        let cycle = elapsed.truncatingRemainder(dividingBy: totalDistance / speed + delay)
        if cycle < delay { return 0 }
        return -min((cycle - delay) * speed, totalDistance)
    }
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                let offset = currentOffset(at: context.date)
                HStack(spacing: 40) {
                    Text(text)
                        .font(font)
                        .tracking(tracking)
                        .foregroundColor(color)
                        .fixedSize()
                    if needsScrolling {
                        Text(text)
                            .font(font)
                            .tracking(tracking)
                            .foregroundColor(color)
                            .fixedSize()
                    }
                }
                .offset(x: offset)
            }
            .clipped()
            .onAppear {
                containerWidth = geo.size.width
            }
            .onChange(of: text) {
                isAnimating = false
                textWidth = 0
            }
            .background(
                Text(text)
                    .font(font)
                    .tracking(tracking)
                    .fixedSize()
                    .hidden()
                    .background(GeometryReader { textGeo in
                        Color.clear.onAppear {
                            textWidth = textGeo.size.width
                            if textWidth > containerWidth {
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    startTime = .now
                                    isAnimating = true
                                }
                            }
                        }
                    })
                    .id(text)
            )
        }
    }
}
