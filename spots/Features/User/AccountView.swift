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

    var body: some View {
        Group {
            if userIds.isEmpty {
                ContentUnavailableView("No one yet", systemImage: "person.slash")
            } else {
                List(userIds, id: \.self) { userId in
                    Text(userId)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
