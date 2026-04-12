//
//  TrackChartView.swift
//  TrackSense
//
//  Created by Russal Arya on 12/4/2026.
//

import SwiftUI
import MusicKit
import Charts

struct TrackChartView: View {
    let tracks: MusicItemCollection<Track>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(
                title: "Tracks",
                subtitle: "See your tracks' plays in a glance",
                hasLeadingPadding: false
            )
            
            Chart {
                ForEach(tracks, id: \.id) { track in
                    if let count = track.playCount {
                        BarMark(
                            x: .value("Plays", count),
                            y: .value("Track", track.title)
                        )
                        .annotation(position: .trailing, alignment: .leading, spacing: 6) {
                            Text("\(count)")
                                .font(.montserrat(size: 12, weight: .bold))
                                .foregroundStyle(.primary.opacity(0.85))
                        }
                        .foregroundStyle(.primary)
                        .cornerRadius(4)
                    }
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks { value in
                    if value.as(String.self) != nil {
                        AxisValueLabel()
                            .foregroundStyle(.primary.opacity(0.7))
                            .font(.montserrat(size: 12, weight: .medium))
                    }
                }
            }
            .frame(height: CGFloat(44 * tracks.count))
        }
    }
}
