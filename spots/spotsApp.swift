//
//  spotsApp.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        let fm = FirebaseManager.init()
        
        print("printing printing printing")
        print(fm.getPostLocation(postCoords: (38.20306, -85.77000)))
        
        return true
    }
}

@main
struct spotsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
