//
//  FeedbackViewButton.swift
//  spots
//
//  Created by Aiden Gage on 2/11/26.
//

import SwiftUI

struct FeedbackViewButton: View {
    
    @Binding var path: NavigationPath
    @State var showFeedbackList: Bool = false
    
    var body: some View {
        Button(action: {
            if !showFeedbackList {
                showFeedbackList = true
//                print(showFeedbackList)
//                path.append(showFeedbackList)
            } else {
                showFeedbackList = false
//                print(showFeedbackList)
            }
            
        }) {
            Label("feedback", systemImage: "bubble.right")
        }
        .buttonStyle(.glassProminent)
        .tint(.purple)
//        .navigationDestination(isPresented: $showFeedbackList) {
//            FeedbackView(path: $path, feedback: Firebase.shared.feedbacks)
//        }
        .sheet(isPresented: $showFeedbackList) {
            FeedbackView(path: $path, feedback: Firebase.shared.feedbacks)
        }
    }
}
