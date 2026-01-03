//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Map {
                Marker("Churchill Downs", coordinate: CLLocationCoordinate2D(latitude: 38.20306, longitude: -85.77000)).tint(.orange)
                Marker("Muhammad Ali Airport", coordinate: CLLocationCoordinate2D(latitude: 38.17410, longitude: -85.73650)).tint(.blue)
                Marker("Cherokee Park", coordinate:CLLocationCoordinate2D(latitude: 38.24120, longitude: -85.69690)).tint(.gray)
                Marker("Falls of the Ohio", coordinate:CLLocationCoordinate2D(latitude:38.2731227, longitude: -85.7591351)).tint(.green)
            }
            .cornerRadius(55)
            .padding(10)
            .ignoresSafeArea(.all)
            
            Button(action: {}) {

                Menu {
                    Button(action: getDocs) {
                        Label("Print Docs", systemImage: "document")
                    }
                    Button(action: {}) {
                        Label("add post", systemImage: "mappin")
                    }
                } label: {
                    Text("more actions")
                        .font(Font.title)
//                        .padding(-8)
                }
            }
            .buttonStyle(.glass)
//            .tint(Color(.clear))
            .glassEffect()
//            .shadow(color: .clear, radius: 10, y: 5)
//            .contextMenu {
//                Button {
//                } label: {
//                    Label("do something here", systemImage: "heart")
//                }
//                Button {
//                } label: {
//                    Label("add post", systemImage: "mappin")
//                }
//            }
        }
    }
}

let fm = FirebaseManager()

func getDocs() {
//    fm.getPostBy_u9mohOI4BugTXOh0tYgQ()
    fm.getDocs()
}

#Preview {
    ContentView()
}
