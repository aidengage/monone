//
//  ProfileButton.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI

struct ProfileButton: View {
    @Binding var profileToggle: Bool
    var body: some View {
        Button(action: {
            if !profileToggle {
                profileToggle = true
//                profileToggle = false
                print("profile button clicked, starting user post listener")
                Firebase.shared.startUserPostListener(userId: Firebase.shared.getCurrentUserID())
            } else {
                profileToggle = false
//                profileToggle = true
                print("profile button clicked, starting post listener")
                Firebase.shared.startPostListener()
            }
        }) {
            Label("profile", systemImage: "person.crop.circle")
        }
        .tint(profileToggle ? .green : .red)
        .buttonStyle(.glassProminent)
    }
}
