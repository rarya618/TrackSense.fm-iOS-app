import AVKit

struct AirPlayButton: UIViewRepresentable {
    var tintColor: UIColor = .white
    var activeTintColor: UIColor = .systemBlue

    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.activeTintColor = activeTintColor
        view.tintColor = tintColor
        view.prioritizesVideoDevices = false // audio only
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}