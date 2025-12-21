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
            Marker("Churchill Downs", coordinate: CLLocationCoordinate2D(latitude: 38.20306, longitude: -85.77000))
            Marker("Muhammad Ali Airport", coordinate: CLLocationCoordinate2D(latitude: 38.17410, longitude: -85.73650))
            Marker("Cherokee Park", coordinate:CLLocationCoordinate2D(latitude: 38.24120, longitude: -85.69690))
        }.cornerRadius(60).padding(15)
    }
}

#Preview {
    ContentView()
}
