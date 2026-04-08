//
//  FlowLayout.swift
//  MusicApp
//
//  Created by Russal Arya on 11/10/2025.
//
import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var rowSpacing: CGFloat = 6
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width + spacing > maxWidth {
                // new line
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + (x == 0 ? 0 : spacing)
        }

        return CGSize(width: maxWidth.isFinite ? maxWidth : x, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var rowStartIndex = 0

        func placeRow(from start: Int, to end: Int, y: CGFloat, rowHeight: CGFloat) {
            var currentX: CGFloat = 0
            for i in start..<end {
                let size = subviews[i].sizeThatFits(.unspecified)
                let point = CGPoint(x: bounds.minX + currentX, y: bounds.minY + y)
                subviews[i].place(at: point, proposal: ProposedViewSize(width: size.width, height: size.height))
                currentX += size.width + spacing
            }
        }

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0 && x + size.width + spacing > maxWidth {
                placeRow(from: rowStartIndex, to: index, y: y, rowHeight: rowHeight)
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
                rowStartIndex = index
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + (x == 0 ? 0 : spacing)
        }

        // place last row
        placeRow(from: rowStartIndex, to: subviews.count, y: y, rowHeight: rowHeight)
    }
}
