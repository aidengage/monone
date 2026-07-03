//
//  MapComponents.swift
//  spots
//
//  Created by Aiden Gage on 7/2/26.
//

import SwiftUI
import MapKit

struct MapCurrentLocation: MapContent {
    var hasValidLocation: Bool
    var latitude: Double
    var longitude: Double
    
    var body: some MapContent {
        if hasValidLocation { // shouldnt need this
            Annotation("Current Location", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }
}

struct PostFilter: MapContent {
    var profileToggle: Bool
    var showOnlyBookmarked: Bool
    @Binding var postsToShow: [Post]
    
    @Environment(\.db) private var dbService
    @Environment(\.user) private var userService
    
    var body: some MapContent {
        
        
        ForEach(postsToShow.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }) { post in
            Marker(post.name, systemImage: ActivityType.from(post.selectedActivity).icon, coordinate: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude))
                .tag(post)
                .tint(ActivityType.from(post.selectedActivity).color) // throws the warning for some reason for unknown even when it is not unknown
            
        }
    }
}

