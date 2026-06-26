//
//  spotsApp.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


final class DependencyContainer {
    lazy var authService: authServiceProtocol = spots.authService()
    lazy var dbService: dbServiceProtocol = spots.dbService()
    lazy var storageService: storageServiceProtocol = spots.storageService()
    
    lazy var UserService: UserServiceProtocol = spots.UserService(authService: authService, dbService: dbService)
    lazy var PostService: PostServiceProtocol = spots.PostService(authService: authService, dbService: dbService, storageService: storageService)
    lazy var RatingService: RatingServiceProtocol = spots.RatingService(authService: authService, dbService: dbService)
    lazy var FeedbackService: FeedbackServiceProtocol = spots.FeedbackService(authService: authService, dbService: dbService, storageService: storageService)
}

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
    
//    @State private var auth: authService = authService()
//    @State private var db: dbService = dbService()
//    @State private var storage: storageService = storageService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
//                .environment(auth)
//                .environment(db)
//                .environment(storage)
        }
    }
}
