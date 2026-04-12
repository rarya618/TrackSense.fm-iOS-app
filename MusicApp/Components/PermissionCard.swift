//
//  PermissionCard.swift
//  TrackSense
//
//  Created by Russal Arya on 25/3/2026.
//

import SwiftUI

struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    var buttonText: String = "I agree"
    var isAuthorised: Bool = false
    let buttonAction: () -> Void
    
    private var accentColor: Color { isAuthorised ? .green : .red }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.08))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.montserrat(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 40) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.montserrat(size: 20, weight: .bold))
                        .foregroundColor(accentColor)
                        .padding(.vertical, 2)
                    
                    if !isAuthorised {
                        Text(description)
                            .font(.montserrat(size: 17))
                            .lineSpacing(9)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                    
                if !isAuthorised {
                    // Button to action permission tasks
                    StandardButton(
                        label: buttonText,
                        bgColor: accentColor,
                        action: buttonAction
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, isAuthorised ? 20 : 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.25), lineWidth: 1)
        )
    }
}

