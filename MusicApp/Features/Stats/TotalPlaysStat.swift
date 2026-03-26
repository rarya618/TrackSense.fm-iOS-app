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
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.customPurple)

                            Text("hours of music played")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.customLightPurple)
                        }

                        Spacer()

                        Button(action: {
                            toggleLibraryHoursSheet()
                        }) {
                            HStack {
                                Image(systemName: "chart.xyaxis.line")
                                    .font(.system(size: 18))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 10)
                            .foregroundColor(.resonatePurple)
                            .glassEffect()
                        }
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
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.customLightPurple)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
    }
}
