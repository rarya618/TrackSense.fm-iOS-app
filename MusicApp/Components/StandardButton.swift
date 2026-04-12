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
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .foregroundStyle(color)
                .font(.montserrat(size: 17, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(bgColor)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .disabled(isDisabled)
    }
}
