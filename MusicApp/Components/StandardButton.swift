//
//  StandardButton.swift
//  Resonate
//
//  Created by Russal Arya on 19/10/2025.
//

import SwiftUI

struct StandardButton: View {
    let label: String
    var bgColor: Color = .resonatePurple
    var color: Color = .resonateWhite
    let action: () -> Void
    
    var body: some View {
        Button(label) {
            action()
        }
        .foregroundColor(color)
        .font(.montserrat(size: 16, weight: .bold))
        .padding()
        .frame(maxWidth: .infinity)
        .background(bgColor)
        .contentShape(Rectangle())
        .cornerRadius(12)
    }
}
