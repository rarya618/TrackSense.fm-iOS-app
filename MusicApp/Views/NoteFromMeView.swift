//
//  NoteFromMeView.swift
//  TrackSense
//
//  Created by Russal Arya on 25/3/2026.
//

import SwiftUI

struct NoteFromMeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("A note from me")
                .font(.montserrat(size: 26, weight: .bold))
                .lineSpacing(8)
                .foregroundColor(.resonatePurple)
            
            // Body paragraphs
            Group {
                Text("Hi!")
                
                Text("I am glad to have you here.")
                
                Text({
                    var s = AttributedString("I built TrackSense.fm because I wanted a better way to explore my own music journey and see how I can display it best to understand my listening habits.")
                    if let range = s.range(of: "TrackSense.fm") {
                        s[range].inlinePresentationIntent = .stronglyEmphasized
                    }
                    return s
                }())
                .foregroundColor(.primary)
                
                Text("It grew into something much bigger, with all these graphs and trends. And now, here we are!")
                
                Text({
                    var s = AttributedString("To get your personal insights ready, I need your help with two things:")
                    if let range = s.range(of: "two") {
                        s[range].inlinePresentationIntent = .stronglyEmphasized
                    }
                    return s
                }())
                .foregroundColor(.primary)
            }
            .font(.montserrat(size: 16))
            .lineSpacing(8)
            .foregroundColor(.primary)
            
            // Feature cards
            FeatureCard(
                icon: "music.note",
                title: "Access to Apple Music",
                description: "I'll use this to pull in your listening history (nothing else!). You'll need an active Apple Music subscription to make the magic happen."
            )
            
            FeatureCard(
                icon: "cloud.fill",
                title: "Sync with cloud",
                description: "I sync your data to the cloud so it's always ready for you. It's fully anonymised, and no identifying personal info ever touches the server."
            )
            
            // Footer paragraphs
            Group {
                Text("If you're not down for these, no hard feelings! But I won't be able to show you your insights without them.")
                
                Text("Ready to vibe?")
                
                Text("Love, Russ")
            }
            .font(.montserrat(size: 16))
            .lineSpacing(8)
            .foregroundColor(.primary)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    private let accentColor = Color.resonatePurple
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.resonatePurple.opacity(0.08))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.montserrat(size: 15))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.montserrat(size: 17, weight: .bold))
                    .foregroundColor(accentColor)
                
                Text(description)
                    .font(.montserrat(size: 16))
                    .lineSpacing(8)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.resonatePurple.opacity(0.06))
                .stroke(Color.resonatePurple.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    NoteFromMeView()
}
