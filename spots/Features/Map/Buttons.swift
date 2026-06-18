//
//  ProfileButton.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI
import Combine
import FirebaseAuth

struct Buttons {

    struct AddButton: View {
        
        @State private var showAddPost = false
        @State private var showLogin = false
        
        @Binding var path: NavigationPath
    //    This lets Add​Button use the same navigation stack as its parent (your Map​View). When it appends to path, it navigates to another screen within the same stack.

        
        @Binding var centerLat: Double
        @Binding var centerLong: Double
        //these get updated by MapView using .onMapCameraChange
        var body: some View {
            NavigationStack(path: $path) {
                
                
                Button(action: {
                    let currentUser = Firebase.shared.getCurrentUser()
                    print("Current user: \(currentUser?.email ?? "nil")")
                    print("User ID: \(currentUser?.uid ?? "nil")")
                    
                    // when logged in, showAddPost is true, appends to path stack with variable
                    if currentUser != nil {
                        showAddPost = true
                    } else {
                        showLogin = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .padding(10)
                }
                .buttonStyle(.glass(.clear))
                .buttonBorderShape(.circle)
                .padding(.leading, 20)
                
                // navigation logic for login and addpost, sending center coords with the navigation
                .sheet(isPresented: $showAddPost) {
                    AddPostView(centerLat: centerLat, centerLong: centerLong)
                        .presentationDetents([.fraction(0.75)])
                }
                .navigationDestination(isPresented: $showLogin) {
                    LoginView()
                }
            }
        }
    }

    struct FriendsMapButton: View {
        @ObservedObject var viewModel: ButtonsViewModel
        
        var body: some View {
            
                Button(action: {
                    viewModel.showOnlyFriends.toggle()
                    if viewModel.showOnlyFriends {
                        viewModel.showOnlyBookmarked = false
                    }
                }) {
                    Image(systemName: viewModel.showOnlyFriends ? "person.2.fill" : "person.2")
                        .font(.title)
                        .padding(1)
                }
                .tint(viewModel.showOnlyFriends ? .blue : .clear)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
            
        }
    }
    
    struct ProfileButton: View {
        @ObservedObject var viewModel: ButtonsViewModel
        
        var body: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.profileToggle.toggle()
                    viewModel.showSmoke = false
                    viewModel.showDate = false
                    viewModel.showPhoto = false
                    viewModel.showTrain = false
                    viewModel.showUnknown = false
                    if !viewModel.profileToggle {
                        viewModel.showOnlyBookmarked = false
                        viewModel.showOnlyFriends = false
                    }
                }
            }) {
                Image(systemName: "person.crop.circle")
                    .font(.largeTitle)
                    .padding(10)
            }
            .tint(viewModel.profileToggle ? .green : .clear)
            .buttonStyle(.glassProminent)
        }
    }
    
    struct BookmarkButton: View {
        @ObservedObject var viewModel: ButtonsViewModel
        
        var body: some View {
            
                Button(action: {
                    viewModel.showOnlyBookmarked.toggle()
                    if viewModel.showOnlyBookmarked {
                        viewModel.showOnlyFriends = false
                    }
                }) {
                    Image(systemName: viewModel.showOnlyBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title)
                        .padding(1)
                }
//                .tint(viewModel.showOnlyBookmarked ? .blue : .clear)
                .tint(.red)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
            
        }
    }
    
    struct AccountButton: View {
        @ObservedObject var viewModel: ButtonsViewModel
        @Binding var path: NavigationPath
        
        var body: some View {
            Button(action: {
                viewModel.showFollowing.toggle()
            }) {
                Image(systemName: "person.text.rectangle")
                    .font(.title)
                    .padding(1)
                    
            }
            .tint(.purple)
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .navigationDestination(isPresented: $viewModel.showFollowing) {
                AccountView(path: $path)
            }
        }
    }
    
    struct LogoutButton: View {
        
        var body: some View {
            Button(action: {
                Firebase.shared.logout()
            }) {
                Image(systemName: "arrow.right.square")
                    .font(.title)
                    .padding(1)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
        }
    }
    
    struct FeedbackButton: View {
        
//        @Binding var path: NavigationPath
        @State var showFeedback: Bool = false
        
        var body: some View {
            NavigationStack(/*path: $path*/) {
                Button(action: {
                    showFeedback.toggle()
                }) {
                    Label("feedback", systemImage: "bubble.left")
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .navigationDestination(isPresented: $showFeedback) {
                    FeedbackForm(/*path: $path*/)
                }
            }
        }
    }
    
    struct SettingsButton: View {
        @State var showSettings: Bool = false
        
        var body: some View {
            NavigationStack() {
                Button(action: {
                    showSettings.toggle()
                }) {
                    Label("settings", systemImage: "gear")
                }
                .buttonStyle(.glassProminent)
                .tint(.teal)
                .navigationDestination(isPresented: $showSettings) {
                    SettingsView()
                }
            }
        }
    }
    
    struct ActivityFilter: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
            Menu {
                filterRow("Smoke", chosen: .smoke, isOn: viewModel.showSmoke)
                filterRow("Date", chosen: .date, isOn: viewModel.showDate)
                filterRow("Photography", chosen: .photography, isOn: viewModel.showPhoto)
                filterRow("Train Station", chosen: .trainStation, isOn: viewModel.showTrain)
                filterRow("Unknown", chosen: .unknown, isOn: viewModel.showUnknown)
            } label: {
                Label("Filters", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(.glassProminent)
        }

        @ViewBuilder
        private func filterRow(_ title: String, chosen: ActivityType, isOn: Bool) -> some View {
            Button {
                viewModel.toggleActivityFilter(chosen)
            } label: {
                Label(
                    isOn ? "Hide \(title)" : "\(title)",
                    systemImage: chosen.icon
                )
            }
        }
    }
}

extension Buttons {
    
    class ButtonsViewModel: ObservableObject {
        @Published var showAll: Bool = true
        
        @Published var profileToggle: Bool = false
        @Published var showOnlyBookmarked: Bool = false
        @Published var showFollowing: Bool = false
        @Published var showOnlyFriends: Bool = false
        
        @Published var showSmoke: Bool = false
        @Published var showDate: Bool = false
        @Published var showPhoto: Bool = false
        @Published var showTrain: Bool = false
        @Published var showUnknown: Bool = false
        
        func startPostListenerForMode() {
            if profileToggle {
                if showOnlyBookmarked {
                    Firebase.shared.startPostListener()
                } else if showOnlyFriends {
                    Firebase.shared.startFollowingPostListener()
                } else {
                    Firebase.shared.startUserPostListener(userId: Firebase.shared.getCurrentUserID())
                }
            } else if showOnlyFriends {
                Firebase.shared.startFollowingPostListener()
            } else {
                Firebase.shared.startPostListener()
            }
        }

        func toggleActivityFilter(_ activity: ActivityType) {
            switch activity {
            case .smoke:
                showSmoke.toggle()
                showDate = false
                showPhoto = false
                showTrain = false
                showUnknown = false
                if showSmoke {
                    Firebase.shared.startPostActivityListener(activity: .smoke)
                } else {
                    startPostListenerForMode()
                }
            case .date:
                showSmoke = false
                showDate.toggle()
                showPhoto = false
                showTrain = false
                showUnknown = false
                if showDate {
                    Firebase.shared.startPostActivityListener(activity: .date)
                } else {
                    startPostListenerForMode()
                }
            case .photography:
                showSmoke = false
                showDate = false
                showPhoto.toggle()
                showTrain = false
                showUnknown = false
                if showPhoto {
                    Firebase.shared.startPostActivityListener(activity: .photography)
                } else {
                    startPostListenerForMode()
                }
            case .trainStation:
                showSmoke = false
                showDate = false
                showPhoto = false
                showTrain.toggle()
                showUnknown = false
                if showTrain {
                    Firebase.shared.startPostActivityListener(activity: .trainStation)
                } else {
                    startPostListenerForMode()
                }
            case .unknown:
                showSmoke = false
                showDate = false
                showPhoto = false
                showTrain = false
                showUnknown.toggle()
                if showUnknown {
                    Firebase.shared.startPostActivityListener(activity: .unknown)
                } else {
                    startPostListenerForMode()
                }
            }
        }
    }
    
}
