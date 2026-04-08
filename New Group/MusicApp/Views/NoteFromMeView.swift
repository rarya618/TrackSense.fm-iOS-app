//
//  NoteFromMeView.swift
//  TrackSense
//
//  Created by Russal Arya on 25/3/2026.
//

import SwiftUI

struct NoteFromMeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Title
                Text("A note from me")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.22, blue: 0.45))
                
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
                .font(.body)
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
                .font(.body)
                .foregroundColor(.primary)
            }
            .padding(20)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    private let accentColor = Color(red: 0.28, green: 0.32, blue: 0.65)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.95))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .foregroundColor(accentColor)
                        .font(.system(size: 15))
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.93, green: 0.93, blue: 0.97))
        .cornerRadius(14)
    }
}

#Preview {
    NoteFromMeView()
}
