//
//  CustomPicker.swift
//  Resonate
//
//  Created by Russal Arya on 5/10/2025.
//

import SwiftUI
import MusicKit

struct CustomPicker: View {
    var color: Color
    var currentSection: Int
    var setCurrentSection: (Int) -> Void
    var options: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options.indices, id: \.self) { index in
                    let label = options[index]
                    
                    Text(label)
                        .font(.montserrat(size: 16, weight: currentSection == index ? .bold : .regular))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .lineLimit(1)
                        .foregroundColor(currentSection == index ? Color.resonateWhite : color)
                        .clipShape(RoundedRectangle(cornerRadius: .infinity))
                        .background(color.opacity(currentSection == index ? 1 : 0.12))
                        .cornerRadius(.infinity)
                        .onTapGesture {
                            setCurrentSection(index)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}
