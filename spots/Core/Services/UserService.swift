//
//  UserService.swift
//  spots
//
//  Created by Aiden Gage on 6/22/26.
//

import SwiftUI

@Observable
class UserService {
    @Environment
    
    var bookmarkedPostIds: [String] = []
    var followers: [String] = []
    var followings: [String] = []
    
    func isFollowingUser(userId: String) -> Bool {
        return followings.contains(userId)
    }
    
    func isFollowedByUser(userId: String) -> Bool {
        return followers.contains(userId)
    }
    
    func getFollowingCount(userId: String) -> Int {
        return followings.count
    }
    
    func getFollowersCount(userId: String) -> Int {
        return followers.count
    }
    
    func loadBookmarks() {
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
            db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("error loading bookmarks: \(error)")
                    return
                }
                //snapshot fetches the raw json so this takes the raw json and converts it to a user object in Swift
                if let user = try? snapshot?.data(as: User.self) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        //taking the bookmarks from Firestore and copying them here into our global var so our app can use it locally
                        self.bookmarkedPostIds = user.bookmarkedPostIds
                    }
                }
            }
        }
    }
    
    //load followers and following
    func loadUserSocials(){
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
            db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("error loading user socials: \(error)")
                    return
                }
                if let user = try? snapshot?.data(as: User.self){
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.followerUserIds = user.followers
                        self.followingUserIds = user.following
                    }
                }
            }
        }
    }
    
    func getUsername(uid: String) async throws -> String {
        try await withCheckedContinuation { continuation in
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("error getting username: \(error)")
                    return
                }
                if let user = try? snapshot?.data(as: User.self){
                    continuation.resume(returning: user.username)
                }
                else {
                    continuation.resume(returning: "")
                }
            }
        }
        
    }
    
    func updateBookmarkedPostIds(_ ids: [String]) {
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
            db.collection("users").document(uid).updateData(["bookmarkedPostIds": ids]) { [weak self] error in
                if let error = error {
                    print("error updating bookmarks: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    self?.bookmarkedPostIds = ids
                }
            }
        }
    }
    func followUser(targetUserId: String){
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
            //only update if userId is not  because you can't follow yourself
            if targetUserId != uid {
                //
                
                //add to curr user's following list
                //also only add if not already following
                if !followingUserIds.contains(targetUserId) {
                    db.collection("users").document(uid).updateData(["following": FieldValue.arrayUnion([targetUserId])]) { [weak self] error in
                        if let error = error {
                            print("error adding to following list: \(error)")
                            return
                        }
                        else{
                            DispatchQueue.main.async {
                                self?.followingUserIds.append(targetUserId)
                            }
                            print("user followed")
                        }
                    }
                }
                
                db.collection("users").document(targetUserId).updateData(["followers": FieldValue.arrayUnion([uid])]) { error in
                    if let error = error {
                        print("error adding to followers list: \(error)")
                    }
                }
                
            }
            
        }
    }
    func unfollowUser(targetUserId: String){
        let uid = getCurrentUserID()
        if uid.isEmpty {
            return
        }
        else{
            //remove from curr user's following list
            if followingUserIds.contains(targetUserId) {
                db.collection("users").document(uid).updateData(["following": FieldValue.arrayRemove([targetUserId])]) { [weak self] error in
                    if let error = error {
                        print("error removing from following list: \(error)")
                        return
                    }
                    else{
                        DispatchQueue.main.async {
                            self?.followingUserIds.removeAll { $0 == targetUserId }
                        }
                        print("user unfollowed")
                    }
                }
            }
            
            db.collection("users").document(targetUserId).updateData(["followers": FieldValue.arrayRemove([uid])]) { error in
                if let error = error {
                    print("error removing from followers list: \(error)")
                }
            }
        }
    }
}
