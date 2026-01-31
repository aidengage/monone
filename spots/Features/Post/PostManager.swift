//
//  PostMan.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI
import MapKit

// post manager service/class file to represent a post obejct
// need to change image to something like an array of [images] to link them to posts
// still need to rework database for users/posts

// codable user obejct to send to firebase database
struct Post: Codable, Identifiable {
    let id: String
    let userId: String
    let images: [String]
    let name: String
    let address: String
    let ratingCount: Int
    let latitude: Double
    let longitude: Double
    let avgRating: Decimal
    let selectedActivity: String
//    let createdAt: Date?
//    let updatedAt: Date?
}

struct PostMan: Identifiable {
    let id: String
    let userId: String
    let title: String
    let images: [String]
    let coords: (Double, Double)
    let address: String
    let rating: Decimal
    let selectedActivity: String
    
    init(from post: Post) {
        self.id = post.id
        self.userId = post.userId
        self.title = post.name
        self.images = post.images
        self.coords = (post.latitude, post.longitude)
        self.address = post.address
        self.rating = post.avgRating
        self.selectedActivity = post.selectedActivity
    }
    
    // initializes a post manager object
    init(docId: String, userId: String, title: String, images: [String], coords: (Double, Double), address: String, rating: Decimal, selectedActivity: String) {
        self.id = docId
        self.userId = userId
        self.title = title
        self.images = images
        self.coords = coords
        self.address = address
        self.rating = rating
        self.selectedActivity = selectedActivity
    }
    
    // creates marker at post coords
    func createMarkerForPost() -> some MapContent {
        return Marker(title, coordinate: CLLocationCoordinate2D(latitude: coords.0, longitude: coords.1))
            .tint(.red)
    }
}
