//
//  AudioQualityCard.swift
//  Resonate
//

import SwiftUI
import MusicKit

struct AudioQualityCard: View {
    let isAppleDigitalMaster: Bool?
    let audioVariants: [AudioVariant]?
    var color: Color = .resonatePurple

    private struct QualityTag {
        let icon: String
        let label: String
    }

    private var tags: [QualityTag] {
        var result: [QualityTag] = []

        if let variants = audioVariants {
            if variants.contains(where: { $0.description == ".highResolutionLossless" }) {
                result.append(QualityTag(icon: "waveform.badge.magnifyingglass", label: "Hi-Res Lossless"))
            } else if variants.contains(where: { $0.description == ".lossless" }) {
                result.append(QualityTag(icon: "waveform", label: "Lossless"))
            } else if variants.isEmpty {
                result.append(QualityTag(icon: "waveform", label: "AAC 256 kbps"))
            }

            if variants.contains(where: { $0.description == ".dolbyAtmos" }) {
                result.append(QualityTag(icon: "dot.radiowaves.left.and.right", label: "Dolby Atmos"))
            }
        }

        if isAppleDigitalMaster == true {
            result.append(QualityTag(icon: "checkmark.seal.fill", label: "Apple Digital Master"))
        }

        return result
    }

    var body: some View {
        if !tags.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(
                    title: "Audio Quality",
                    subtitle: "Format and encoding details"
                )

                FlowLayout(spacing: 8, rowSpacing: 8) {
                    ForEach(tags.indices, id: \.self) { i in
                        Label(tags[i].label, systemImage: tags[i].icon)
                            .font(.montserrat(size: 14, weight: .medium))
                            .tracking(14 * -0.025)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(color.opacity(0.07))
                            .foregroundStyle(color)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 1))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
