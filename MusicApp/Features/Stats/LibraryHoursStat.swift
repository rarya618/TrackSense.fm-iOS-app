//
//  LibraryHoursStat.swift
//  Resonate
//
//  Created by Russal Arya on 9/11/2025.
//

import SwiftUI

struct LibraryHoursStat: View {
    var hours: Int
    let toggleLibraryHoursSheet: () -> Void
    
    var days: Int {
        Int(hours / 24)
    }

    var body: some View {
        HStack {
            if (hours == 0) {
                // Loading state
                VStack {
                    ClassicLoadingView(text: "Loading library stats")
                }
            } else {
                VStack (alignment: .leading, spacing: 16) {
                    HStack (alignment: .top) {
                        VStack (alignment: .leading, spacing: 2) {
                            Text(hours.formatted())
                                .font(.montserrat(size: 32, weight: .bold))
                            .foregroundStyle(Color.customPurple)

                            Text("hours of music played")
                            .font(.montserrat(size: 16, weight: .bold))
                            .foregroundStyle(Color.customLightPurple)
                        }

                        Spacer()

                        Button(action: {
                            toggleLibraryHoursSheet()
                        }) {
                            HStack {
                                Image(systemName: "chart.xyaxis.line")
                                    .font(.montserrat(size: 18))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                            .foregroundColor(.resonatePurple)
                            .background(
                                Capsule()
                                    .fill(Color.resonatePurple.opacity(0.12))
                            )                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text({
                        var s = AttributedString("That’s around ")
                        var d = AttributedString("\(days.formatted()) days")
                        d.inlinePresentationIntent = .stronglyEmphasized
                        s.append(d)
                        s.append(AttributedString(" worth of music"))
                        return s
                    }())
                    .font(.montserrat(size: 12, weight: .regular))
                    .foregroundStyle(Color.customLightPurple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.resonatePurple.opacity(0.3), lineWidth: 1)
        )
    }
}
