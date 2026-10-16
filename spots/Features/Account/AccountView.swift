//
//  AccountView.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI

struct AccountView: View {
    @Environment(\.user) private var userService
    
    @State private var followerUserIds: [String] = []
    @State private var followingUserIds: [String] = []
    
    var usernames: [String] = []
    
    @State private var showFollowers: Bool = false
    @State private var showFollowing: Bool = false
    
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    Text("\(followerUserIds.count) followers · \(followingUserIds.count) following")
                        .font(.headline)
                }
                Button(action: {
                    showFollowers.toggle()
                }) {
                    Text("Followers")
                }
                Button(action: {
                    showFollowing.toggle()
                }) {
                    Text("Following")
                }
            }
        }
        .navigationDestination(isPresented: $showFollowers) {
            SocialListView(title: "Followers", userIds: followerUserIds)
        }
        .navigationDestination(isPresented: $showFollowing) {
            SocialListView(title: "Following", userIds: followingUserIds)
        }
        .navigationTitle("Account")
        .onAppear {
            refreshSocials()
        }
    }

    private func refreshSocials() {
        followerUserIds = userService.getFollowers()
        followingUserIds = userService.getFollowing()
        Task {
            try await userService.loadUserSocials()
        }
        
        // Firestore callback is async; sync again shortly so counts/lists update after load.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            followerUserIds = userService.getFollowers()
            followingUserIds = userService.getFollowing()
        }
    }
}

struct SocialListView: View {
    @Environment(\.user) private var userService
    let title: String
    let userIds: [String]
    @State var names: [String: String] = [:]

    var body: some View {
        VStack {
            if userIds.isEmpty {
                ContentUnavailableView("No one yet", systemImage: "person.slash")
            } else {
                List(userIds, id: \.self) { userId in
                    Text(names[userId] ?? userId)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .navigationTitle(title)
        .task{
            await loadNames(userIds: userIds)
        }
    }
    
    func loadNames(userIds: [String]) async {
        for id in userIds {
//            do {
                let name = await userService.fetchUsername(userId: id)
                if let namename = name {
                    names[id] = name
                }
                
//            } catch {
////                names[id] = "unknown"
//                print("failed to get username for \(id): \(error)")
//            }
            
            
        }
    }
}

//#Preview {
//    NavigationStack {
//        AccountView()
//    }
//}
