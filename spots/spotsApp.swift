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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
//        let fm = FirebaseManager.init()
        
//        print("printing printing printing")
//        print(fm.getPostLocation(postCoords: (38.20306, -85.77000)))
//        print(fm.getPostByName(postName: "Churchill Downs"))
//        fm.addSnapListener()
//        fm.getPostById(postID: "u9mohOI4BugTXOh0tYgQ")
        
        return true
    }
}

@main
struct spotsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView(centerLat: 0.0, centerLong: 0.0)
        }
    }
}
