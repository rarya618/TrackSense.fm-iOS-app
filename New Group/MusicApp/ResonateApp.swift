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

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
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
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(overlayManager)
                .environmentObject(authManager)
                .background(Color.resonateWhite)
        }
    }
}

