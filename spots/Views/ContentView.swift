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
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                MapView()
            }
        }
    }
}

#Preview {
    ContentView()
}

