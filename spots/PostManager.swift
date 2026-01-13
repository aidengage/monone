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

class PostMan: Identifiable {
    let docId: String
    let title: String
    let description: String
    let images: [String]
    let coords: (Double, Double)
    let address: String
    
    // initializes a post manager object
    init(docId: String, title: String, description: String, images: [String], coords: (Double, Double), address: String) {
        self.docId = docId
        self.title = title
        self.description = description
        self.images = images
        self.coords = coords
        self.address = address
    }
    
    // creates marker at post coords
    func createMarkerForPost() -> some MapContent {
        return Marker(title, coordinate: CLLocationCoordinate2D(latitude: coords.0, longitude: coords.1))
            .tint(.red)
    }
}
