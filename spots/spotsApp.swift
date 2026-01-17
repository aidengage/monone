//
//  spotsApp.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // essentially the main function of our app, configures firebase and return true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        return true
    }
}

// the main view of our app, where we call contentview to start everything
@main
struct spotsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView(centerLat: 0.0, centerLong: 0.0)
        }
    }
}
