//
//  SectionHeader.swift
//  TrackSense
//
//  Created by Russal Arya on 12/4/2026.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String
    var margin: CGFloat = 22
    var hasLeadingPadding: Bool = true
    
    var body: some View {
        Group {
            if hasLeadingPadding {
                headerContent
                    .padding(.leading)
            } else {
                headerContent
            }
        }
        .padding(.bottom, 4)
    }
    
    private var headerContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.montserrat(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.montserrat(size: 15))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
