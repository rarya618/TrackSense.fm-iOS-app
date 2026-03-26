//
//  AirPlayPickerRepresentable.swift
//  MusicApp
//
//  Created by Russal Arya on 12/10/2025.
//


struct AirPlayPickerRepresentable: UIViewRepresentable {
    var tintColor: UIColor
    var activeTintColor: UIColor

    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView(frame: .zero)
        view.tintColor = tintColor
        view.activeTintColor = activeTintColor
        view.prioritizesVideoDevices = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true

        // Hide internal icon
        DispatchQueue.main.async {
            for subview in view.subviews {
                subview.alpha = 0.01 // invisible, but still receives touches
            }
        }

        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.tintColor = tintColor
        uiView.activeTintColor = activeTintColor

        // Keep internal views hidden after SwiftUI updates
        for subview in uiView.subviews {
            subview.alpha = 0.01
        }
    }
}