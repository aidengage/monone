//
//  spotsApp.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25.
//

import SwiftUI
import SwiftData
import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


//final class DependencyContainer {
//    lazy var authService: authServiceProtocol = spots.authService()
//    lazy var dbService: dbServiceProtocol = spots.dbService()
//    lazy var storageService: storageServiceProtocol = spots.storageService()
//    
//    lazy var imageService: imageServiceProtocol = spots.ImageService(storageService: storageService)
//    
//    lazy var userService: userServiceProtocol = spots.UserService(authService: authService, dbService: dbService)
//    lazy var postService: postServiceProtocol = spots.PostService(authService: authService, dbService: dbService, storageService: storageService, ImageService: imageService)
//    lazy var ratingService: ratingServiceProtocol = spots.RatingService(authService: authService, dbService: dbService)
//    lazy var feedbackService: feedbackServiceProtocol = spots.FeedbackService(authService: authService, dbService: dbService, storageService: storageService, imageService: imageService)
//}

@MainActor
private struct DependencyContainer {
    let modelContainer: ModelContainer
    
    let db: dbServiceProtocol
    let auth: authServiceProtocol
    let storage: storageServiceProtocol
    
    let image: imageServiceProtocol
    let user: userServiceProtocol
    let post: postServiceProtocol
    let rating: ratingServiceProtocol
    let feedback: feedbackServiceProtocol
    
    let currentUser: uidProtocol
    let buttonsViewModel: ButtonsViewModel
    let tracker: trackerProtocol
    
    init() {
        do {
            // 2. FIXED: Explicitly register your SwiftData models inside a Schema
            let schema = Schema([ItemData.self]) // Add any other @Model classes to this array
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            
            self.modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("failed to initialize ModelContainer: \(error.localizedDescription)")
        }
        
        
        let db = dbService()
        let auth = authService()
        let storage = storageService()
        
        let image = ImageService(storageService: storage)
        let user = UserService(authService: auth, dbService: db)
        let post = PostService(authService: auth, dbService: db, storageService: storage, imageService: image)
        let rating = RatingService(authService: auth, dbService: db)
        let feedback = FeedbackService(authService: auth, dbService: db, storageService: storage, imageService: image)
        
        let currentUser = UserID()
        let buttonsViewModel = ButtonsViewModel(currentUser: currentUser, dbService: db)
        let tracker = TrackerSyncService(authService: auth, dbService: db)
        
        self.db = db
        self.auth = auth
        self.storage = storage
        
        self.image = image
        self.user = user
        self.post = post
        self.rating = rating
        self.feedback = feedback
        
        self.currentUser = currentUser
        self.buttonsViewModel = buttonsViewModel
        self.tracker = tracker
    }
}

extension EnvironmentValues {
    private static let vault = DependencyContainer()
    @Entry var globalModelContext: ModelContainer = vault.modelContainer
    
    @Entry var db: dbServiceProtocol = vault.db
    @Entry var auth: authServiceProtocol = vault.auth
    @Entry var storage: storageServiceProtocol = vault.storage
    
    @Entry var image: imageServiceProtocol = vault.image
    @Entry var user: userServiceProtocol = vault.user
    @Entry var post: postServiceProtocol = vault.post
    @Entry var rating: ratingServiceProtocol = vault.rating
    @Entry var feedback: feedbackServiceProtocol = vault.feedback
    
    @Entry var currentUser: uidProtocol = vault.currentUser
    @Entry var buttonsViewModel: ButtonsViewModel = vault.buttonsViewModel
    @Entry var tracker: trackerProtocol = vault.tracker
}
//
//    @Entry var imageService: imageServiceProtocol
//    @Entry var userService: userServiceProtocol
    
//    var dbService: dbServiceProtocol {
//        get { self[dbServiceProtocol.self] }
//        set { self[dbServiceProtocol.self] = newValue }
//    }
//}

protocol uidProtocol {
    var uid: String? { get set }
    func storeId() async
    func getId() -> String?
}

@Observable
class UserID: uidProtocol {
    var uid: String? = Auth.auth().currentUser?.uid
    var isLoading: Bool = false
    
    func storeId() async {
        isLoading = true
        print("fetching user id: \(String(describing: uid))")
        defer { isLoading = false }
        uid = Auth.auth().currentUser?.uid
        print("user id: \(String(describing: uid))")
        isLoading = false
    }
    
    func getId() -> String? {
        return uid
    }
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
    
    @Environment(\.globalModelContext) private var swiftModelContainer
    @Environment(\.tracker) private var tracker
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .modelContainer(swiftModelContainer)
            
                .task {
                    await MainActor.run {
                        tracker.seedDefaultTrackedItems(context: swiftModelContainer.mainContext)
                    }
                }
        }
    }
}
