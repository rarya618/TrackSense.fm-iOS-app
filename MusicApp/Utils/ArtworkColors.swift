//
//  ArtworkColors.swift
//  Resonate
//

import SwiftUI
import UIKit

extension UIColor {
    var luminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        func adjust(_ v: CGFloat) -> CGFloat {
            (v < 0.03928) ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * adjust(r) + 0.7152 * adjust(g) + 0.0722 * adjust(b)
    }

    func contrastRatio(with other: UIColor) -> CGFloat {
        let l1 = luminance
        let l2 = other.luminance
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }
}

/// Returns whichever of `textColor` or `backgroundColor` has higher contrast against `.resonateWhite`.
func idealColor(textColor: UIColor, backgroundColor: UIColor) -> Color {
    let white = UIColor(.resonateWhite)
    let useBackground = backgroundColor.contrastRatio(with: white) >= textColor.contrastRatio(with: white)
    return Color(useBackground ? backgroundColor : textColor)
}
