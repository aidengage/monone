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
        NavigationView {
            ZStack(alignment: .bottom) {
                Map {
                    Marker("Churchill Downs", coordinate: CLLocationCoordinate2D(latitude: 38.20306, longitude: -85.77000)).tint(.orange)
                    Marker("Muhammad Ali Airport", coordinate: CLLocationCoordinate2D(latitude: 38.17410, longitude: -85.73650)).tint(.blue)
                    Marker("Cherokee Park", coordinate:CLLocationCoordinate2D(latitude: 38.24120, longitude: -85.69690)).tint(.gray)
                    Marker("Falls of the Ohio", coordinate:CLLocationCoordinate2D(latitude:38.2731227, longitude: -85.7591351)).tint(.green)
                }
                .ignoresSafeArea(.all)
                
                VStack {
                    Button(action: getDocs) {
                        Label("Print Docs", systemImage: "document")
                    }
                    NavigationLink {
                        AddPostView()
                    } label: {
                        Label("Add Post", systemImage: "mappin")
                    }
                }
                .buttonStyle(.glass(.clear))
                .glassEffect()
            }
        }
    }
}

let fm = FirebaseManager()

func getDocs() {
//    fm.printDocs()
    fm.getDocs()
}

func addPost() {
    // info will be hardcoded for first test
    fm.addPost(
        image: "https://firebasestorage.googleapis.com/v0/b/monone-swift.firebasestorage.app/o/muhammed%20ali%20airport.jpg?alt=media&token=0fcdb4f6-7b95-4e37-8eb4-1f1c8b1bd149",
        name: "Muhammed Ali Airport",
        address: "600 Terminal Drive, Louisville, KY 40209",
        rating: 4.3,
        description: "this is muhammed ali international airport !",
        coords: (xLoc: 38.174167, yLoc: -85.736389))
}

#Preview {
    ContentView()
}
