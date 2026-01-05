//
//  PostMan.swift
//  spots
//
//  Created by Aiden Gage on 1/4/26.
//

import SwiftUI
import MapKit

class PostMan: Identifiable {
    let docId: String
    let title: String
    let description: String
    let image: String
    let coords: (Double, Double)
    let address: String
    
    init(docId: String, title: String, description: String, image: String, coords: (Double, Double), address: String) {
        self.docId = docId
        self.title = title
        self.description = description
        self.image = image
        self.coords = coords
        self.address = address
    }
    
    func createMarkerForPost() -> some MapContent {
        print("📍 Creating marker for: \(title) at coordinates (\(coords.0), \(coords.1))")
        return Marker(title, coordinate: CLLocationCoordinate2D(latitude: coords.0, longitude: coords.1))
            .tint(.red)
    }
}
