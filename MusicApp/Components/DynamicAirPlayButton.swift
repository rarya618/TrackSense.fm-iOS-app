import SwiftUI
import AVKit
import AVFoundation
import MediaPlayer

struct DynamicAirPlayButton: View {
    var artworkColor: Color
    var primaryColor: Color
    
    @State private var currentOutputIcon = "speaker.wave.2.fill"
    @State private var routeID = UUID()
    
    var body: some View {
        ZStack {
            // Invisible AVRoutePickerView for actual AirPlay handling
            AirPlayPickerRepresentable(
                tintColor: UIColor(artworkColor),
                activeTintColor: UIColor(primaryColor)
            )
            .opacity(0.05) // make it tappable but hidden
            .frame(width: 44, height: 44)
            
            // The visible icon that reflects the current route
            Image(systemName: currentOutputIcon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(primaryColor)
                .frame(width: 44, height: 44)
                .background(artworkColor)
                .cornerRadius(22)
                .accessibilityLabel("AirPlay")
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
            currentOutputIcon = "speaker.wave.2.fill"
            return
        }

        switch output.portType {
        case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
            currentOutputIcon = "airpodspro" // or "headphones" if older iOS
        case .airPlay:
            currentOutputIcon = "airplayaudio"
        case .headphones, .headsetMic:
            currentOutputIcon = "headphones"
        default:
            currentOutputIcon = "speaker.wave.2.fill"
        }
    }
}

struct AirPlayPickerRepresentable: UIViewRepresentable {
    var tintColor: UIColor
    var activeTintColor: UIColor
    
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.tintColor = tintColor
        view.activeTintColor = activeTintColor
        view.prioritizesVideoDevices = false
        return view
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.tintColor = tintColor
        uiView.activeTintColor = activeTintColor
    }
}