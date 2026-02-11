//
//  FeedbackView.swift
//  spots
//
//  Created by Aiden Gage on 2/11/26.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var path: NavigationPath
    let feedback: [Feedback]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(feedback) { feedback in
                        FeedbackCardPreview(type: feedback.feedbackType, status: feedback.status, feedbackId: feedback.id)
                    }
                }
            }
//            Text("FeedbackView")
        }
        .navigationTitle("Feedback posts!!11!!!")
    }
}

struct FeedbackCardPreview: View {
    let type: FeedbackType
    let status: FeedbackStatus
    let feedbackId: String
    // maybe get first little bit of report
    
    var body: some View {
        VStack {
            Text(feedbackId)
            HStack {
                Image(systemName: "exclamationmark.triangle.text.page")
                Text(type.rawValue)
                Text(status.rawValue)
                Button(action: {
                    Task {
                        await Firebase.shared.deleteFeedbackBatch(feedbackId: feedbackId)
                    }
                    
                }) {
                    Label("delete", systemImage: "trash")
                }
            }
        }
    }
}

struct FeedbackInfoView: View {
    let feedback: Feedback
    
    var body: some View {
        
    }
}
