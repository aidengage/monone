//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25
//  Contributions by Minahil starting 01/04/26

// many things happen in this file beware

import SwiftUI
import MapKit
import FirebaseAuth
import Combine

struct ContentView: View {
    // coords for center of the screen, sent to addpost view to autofill
    @State var centerLat: Double
    @State var centerLong: Double

    // part of the navigation stack in body, appending to the end of this will send user to that page
    @State var path = NavigationPath()
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                MainMapView(centerLat: centerLat, centerLong: centerLong, path: $path)
//                FireMigrateButton()
            }
//            AddButton(path: $path, centerLat: centerLat, centerLong: centerLong)
        }
    }
}

#Preview {
    ContentView(centerLat: 0.0, centerLong: 0.0)
}

