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
    @State private var animationWorkItem: DispatchWorkItem? = nil
    
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
            Group {
                if isAnimating && needsScrolling {
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
                } else {
                    // Static rendering when not animating or not needed
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
                    .offset(x: 0)
                }
            }
            .clipped()
            .onAppear {
                containerWidth = geo.size.width
            }
            .onChange(of: geo.size) { _, newSize in
                containerWidth = newSize.width
            }
            .onDisappear {
                animationWorkItem?.cancel()
                animationWorkItem = nil
            }
            .onChange(of: text) {
                animationWorkItem?.cancel()
                animationWorkItem = nil
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
                                let workItem = DispatchWorkItem {
                                    startTime = .now
                                    isAnimating = true
                                }
                                animationWorkItem = workItem
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
                            }
                        }
                        .onChange(of: textGeo.size) { _, _ in
                            // Recalculate text width on size changes
                            textWidth = textGeo.size.width
                        }
                    })
                    .id(text)
            )
        }
    }
}

