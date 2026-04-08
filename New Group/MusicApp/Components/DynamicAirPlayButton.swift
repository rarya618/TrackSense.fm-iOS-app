//
//  DynamicAirPlayButton.swift
//  Resonate
//
//  Created by Russal Arya on 12/10/2025.
//


import SwiftUI
import AVKit
import AVFoundation
import MediaPlayer

struct DynamicAirPlayButton: View {
    var artworkColor: Color
    var primaryColor: Color
    
    @State private var currentOutputIcon = "airplayaudio"
    @State private var routeID = UUID()
    
    var body: some View {
        ZStack {
            // Invisible system picker for taps
            AirPlayPickerRepresentable(
                tintColor: UIColor(artworkColor),
                activeTintColor: UIColor(artworkColor)
            )
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())

            // Your visible custom icon
            Image(systemName: currentOutputIcon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(artworkColor)
                .frame(width: 48, height: 48)
                .background(.clear)
                .cornerRadius(24)
                .allowsHitTesting(false) // let taps pass through
        }
        .id(routeID) // forces rebuild on route change
        .onAppear {
            updateCurrentRoute()
            NotificationCenter.default.addObserver(
                forName: AVAudioSession.routeChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                updateCurrentRoute()
                routeID = UUID()
            }
        }
    }
    
    private func updateCurrentRoute() {
        let session = AVAudioSession.sharedInstance()
        guard let output = session.currentRoute.outputs.first else {
            currentOutputIcon = "airplayaudio"
            return
        }

        switch output.portType {
        case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
            currentOutputIcon = "airpodspro" // or "headphones" if older iOS
        case .airPlay:
            currentOutputIcon = "speaker.wave.2.fill"
        case .headphones, .headsetMic:
            currentOutputIcon = "headphones"
        default:
            currentOutputIcon = "airplayaudio"
        }
    }
}
