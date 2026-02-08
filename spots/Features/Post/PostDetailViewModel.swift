//
//  PostDetailViewModel.swift
//  spots
//
//  Created by Aiden Gage on 2/7/26.
//

import SwiftUI
import FirebaseFirestore

extension PostDetailView {
    @Observable class ViewModel {
//        var post: Post = Post()
//        var ratings: [Rating] = []
        
//        func startPostListenerById(postId: String) {
//            Firebase.shared.stopPostListener()
//            
//            Firebase.shared.postListener = Firebase.shared.getStore().collection("posts").document(postId).addSnapshotListener { [weak self] (snapshot, error) in
//                guard let self = self else { return }
//                
//                if let error = error {
//                    print("Error getting post: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let document = snapshot else {
//                    print("No post found")
//                    return
//                }
//                
//                do {
//                    self.post = try document.data(as: Post.self)
//                } catch {
//                    print("error decoding post: \(error.localizedDescription)")
//                }
//            }
//        }
//        
//        func startRatingListener(postId: String) {
//            Firebase.shared.stopRatingListener()
//           
//            Firebase.shared.ratingListener = Firebase.shared.getStore().collection("ratings")
//               .whereField("postId", isEqualTo: postId)
//               .addSnapshotListener { (snapshot, error) in
////               guard let self = self else { return }
//               
//            if let error = error {
//                print("error getting ratings: \(error.localizedDescription)")
//            }
//           
//            guard let documents = snapshot?.documents else {
//                print("No ratings found")
//                Firebase.shared.ratings = []
//                return
//            }
//           
//                Firebase.shared.ratings = documents.compactMap { document in
//                    do {
//                        let rating = try document.data(as: Rating.self)
//                        return rating
//                    } catch {
//                        print("error decoding rating \(document.documentID): \(error.localizedDescription)")
//                        return nil
//                    }
//                }
//            }
//            print("rating count in post: \(Firebase.shared.ratings.count)")
//        }
    }
}
