//
//  ResonateApp.swift
//  Resonate
//
//  Created by Russal Arya on 17/9/2025.
//

import SwiftUI
import FirebaseCore

extension Color {
    static let resonatePurple = Color("CustomPurple")
    static let resonateLightPurple = Color("CustomLightPurple")
    static let landingPurple = Color("LockedPurple")
    
    static let resonateTurquoise = Color("CustomTurquoise")
    static let resonateLightTurquoise = Color("CustomLightTurquoise")
    
    static let resonateWhite = Color("CustomWhite")
    
    static let buttonColor = Color("Button")
    static let buttonLabelColor = Color("ButtonLabel")
}

extension Font {
    static func montserrat(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold: name = "Montserrat-Bold"
        case .semibold: name = "Montserrat-SemiBold"
        case .medium: name = "Montserrat-Medium"
        default: name = "Montserrat-Regular"
        }
        return .custom(name, size: size)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    let darkThumb = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
    UISwitch.appearance(for: UITraitCollection(userInterfaceStyle: .dark)).thumbTintColor = darkThumb
    UISwitch.appearance(for: UITraitCollection(userInterfaceStyle: .light)).thumbTintColor = .white

    return true
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return .portrait
  }
}

@main
struct ResonateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var overlayManager = OverlayManager()
    
    init() {
        registerFonts()
    }
    
    private func registerFonts() {
        let fonts = [
            "Montserrat-Regular",
            "Montserrat-Medium",
            "Montserrat-SemiBold",
            "Montserrat-Bold"
        ]
        
        fonts.forEach { font in
            guard
                let url = Bundle.main.url(forResource: font, withExtension: "ttf"),
                let data = try? Data(contentsOf: url),
                let provider = CGDataProvider(data: data as CFData),
                let cgFont = CGFont(provider)
            else {
                print("Failed to load font: \(font)")
                return
            }
            if #available(iOS 18.0, *) {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            } else {
                CTFontManagerRegisterGraphicsFont(cgFont, nil)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.font, .custom("Montserrat-Regular", size: 17))
                .environmentObject(overlayManager)
                .environmentObject(authManager)
                .background(Color.resonateWhite)
        }
    }
}

