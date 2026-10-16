//
//  ContentView.swift
//  spots
//
//  Created by Aiden Gage on 12/21/25
//  Contributions by Minahil starting 01/04/26

// many things happen in this file beware

import SwiftUI

struct ContentView: View {
    @Environment(\.auth) private var authService
    
    @State private var activeTab: BottomTabModel = .home
    @State private var showAddPost = false
    @State private var showLogin = false
    @State private var mapCenterLat: Double = 0
    @State private var mapCenterLong: Double = 0
    
    
    var body: some View {
        ZStack {
            MapView(
                feedMode: activeTab.mapFeedMode ?? .home,
                mapCenterLat: $mapCenterLat,
                mapCenterLong: $mapCenterLong
            )
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .bottom) {
            NavBar(tabs: BottomTabModel.allCases, selectedTab: $activeTab)
        }
        .onChange(of: activeTab) { old, new in
            guard new == .add else { return }
            if authService.getAuthStatus() {
                showAddPost = true
            } else {
                showLogin = true
            }
            activeTab = old
//            if new == .add {
//                showAddPost.toggle()
//                activeTab = old
//            }
        }
        .sheet(isPresented: $showAddPost) {
            AddPostView()
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
//        NavBarView()
    }
}

#Preview {
    ContentView()
}
