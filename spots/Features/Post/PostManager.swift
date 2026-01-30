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
struct Post: Codable {
    var images: [String?]
    var name: String?
    var address: String?
    var rating: Decimal?
    var comment: String?
    var latitude: Double?
    var longitude: Double?
//    var ratings: [String?]
    var userID: String?
    var selectedActivity: String?
}

class PostMan: Identifiable {
    let docId: String
    let userId: String
    let title: String
//    let comment: String
    let images: [String]
    let coords: (Double, Double)
    let address: String
    let rating: Decimal
//    let ratings: [Rating]
    let selectedActivity: String
    
    // initializes a post manager object
    init(docId: String, userId: String, title: String, /*comment: String,*/ images: [String], coords: (Double, Double), address: String, rating: Decimal, selectedActivity: String) {
        self.docId = docId
        self.userId = userId
        self.title = title
//        self.comment = comment
        self.images = images
        self.coords = coords
        self.address = address
        self.rating = rating
//        self.ratings = []
        self.selectedActivity = selectedActivity
    }
    
    // creates marker at post coords
    func createMarkerForPost() -> some MapContent {
        return Marker(title, coordinate: CLLocationCoordinate2D(latitude: coords.0, longitude: coords.1))
            .tint(.red)
    }
}
