//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        Map {
            Marker("Churchill Downs", coordinate: CLLocationCoordinate2D(latitude: 38.20306, longitude: -85.77000)).tint(.orange)
            Marker("Muhammad Ali Airport", coordinate: CLLocationCoordinate2D(latitude: 38.17410, longitude: -85.73650)).tint(.blue)
            Marker("Cherokee Park", coordinate:CLLocationCoordinate2D(latitude: 38.24120, longitude: -85.69690)).tint(.gray)
            Marker("Falls of the Ohio", coordinate:CLLocationCoordinate2D(latitude:38.2731227, longitude: -85.7591351)).tint(.green)
        }.cornerRadius(60).padding(15)
    }
}

#Preview {
    ContentView()
}
