//
//  FeedbackButton.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI

struct FeedbackButton: View {
    
    @Binding var path: NavigationPath
    @State var showFeedback: Bool = false
    
    var body: some View {
        Button(action: {
            if !showFeedback {
                showFeedback = true
                path.append(showFeedback)
            } else {
                showFeedback = false
            }
            
        }) {
            Label("feedback", systemImage: "bubble.left")
        }
        .buttonStyle(.glassProminent)
        .tint(.orange)
        .navigationDestination(isPresented: $showFeedback) {
            FeedbackView()
        }
    }
}
