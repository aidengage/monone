//
//  AccountView.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI

struct AccountView: View {
    @State private var followerUserIds: [String] = []
    @State private var followingUserIds: [String] = []
    private var usernames: [String] = []

    var body: some View {
        List {
            Section {
                Text("\(followerUserIds.count) followers · \(followingUserIds.count) following")
                    .font(.headline)
            }

            Section {
                NavigationLink {
                    SocialListView(title: "Followers", userIds: followerUserIds)
                } label: {
                    Text("Followers")
                }

                NavigationLink {
                    SocialListView(title: "Following", userIds: followingUserIds)
                } label: {
                    Text("Following")
                }
            }
        }
        .navigationTitle("Account")
        .onAppear {
            refreshSocials()
        }
    }

    private func refreshSocials() {
        followerUserIds = Firebase.shared.followerUserIds
        followingUserIds = Firebase.shared.followingUserIds
        Firebase.shared.loadUserSocials()
        // Firestore callback is async; sync again shortly so counts/lists update after load.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            followerUserIds = Firebase.shared.followerUserIds
            followingUserIds = Firebase.shared.followingUserIds
        }
    }
}

struct SocialListView: View {
    let title: String
    let userIds: [String]
    @State var names: [String: String] = [:]

    var body: some View {
        Group {
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
//        .onAppear {
            .task{
                await loadNames(userIds: userIds)
            }
            
//        }
    }
    
    func loadNames(userIds: [String]) async {
        for id in userIds {
            do {
                let name = try await Firebase.shared.getUsername(uid: id)
                names[id] = name
            } catch {
//                names[id] = "unknown"
                print("failed to get username for \(id): \(error)")
            }
            
            
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
