//
//  ProfileButton.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI

struct ProfileButton: View {
    @State var profileToggle: Bool
    var body: some View {
        Button(action: {
            if !profileToggle {
                profileToggle = true
//                profileToggle = false
                Firebase.shared.startUserPostListener(userId: Firebase.shared.getCurrentUserID())
            } else {
                profileToggle = false
//                profileToggle = true
                Firebase.shared.startPostListener()
            }
        }) {
            Label("profile", systemImage: "person.crop.circle")
        }
        .tint(profileToggle ? .green : .red)
        .buttonStyle(.glassProminent)
    }
}
