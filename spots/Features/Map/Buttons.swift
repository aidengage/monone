//
//  ProfileButton.swift
//  spots
//
//  Created by Aiden Gage on 2/8/26.
//

import SwiftUI
import Combine

struct Buttons {

    
    
    struct ProfileButton: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
            Button(action: {
                viewModel.profileToggle.toggle()
                viewModel.showSmoke = false
                viewModel.showDate = false
                viewModel.showPhoto = false
                viewModel.showTrain = false
                viewModel.showUnknown = false

                if viewModel.profileToggle {
                    
                    //                profileToggle = false
//                    print("profile button clicked, starting user post listener")
                    Firebase.shared.startUserPostListener(userId: Firebase.shared.getCurrentUserID())
                } else {
                    
                    //                profileToggle = true
//                    print("profile button clicked, starting post listener")
                    Firebase.shared.startPostListener()
                }
            }) {
                Label("profile", systemImage: "person.crop.circle")
            }
            .tint(viewModel.profileToggle ? .green : .red)
            .buttonStyle(.glassProminent)
        }
    }
    
    struct FeedbackButton: View {
        
        @Binding var path: NavigationPath
        @State var showFeedback: Bool = false
        
        var body: some View {
            NavigationStack(path: $path) {
                Button(action: {
                    if !showFeedback {
                        showFeedback = true
                        path.append(showFeedback)
                    } else {
                        showFeedback = false
                    }
                    
                }) {
                    Label("feedback", systemImage: "bubble.left")
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .navigationDestination(isPresented: $showFeedback) {
                    FeedbackForm(path: $path)
                }
            }
        }
    }
    
    struct SmokeFilter: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
            Button(action: {
                viewModel.showSmoke.toggle()
                viewModel.showDate = false
                viewModel.showPhoto = false
                viewModel.showTrain = false
                viewModel.showUnknown = false
                
                if viewModel.showSmoke {
                    Firebase.shared.startPostActivityListener(activity: .smoke)
                } else {
                    viewModel.startPostListenerForMode()
                }
            }) {
                Label(viewModel.showSmoke ? "Hide smoke" : "Show smoke",
                      systemImage: ActivityType.smoke.icon)
//                .opacity(viewModel.showSmoke ? 1.0 : 0.3)
            }
            .tint(ActivityType.smoke.color)
            .buttonStyle(.glassProminent)
//            .background(
//                viewModel.showSmoke ?
//                    ActivityType.smoke.color.opacity(0.2) :
//                    Color.clear
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(
//                        ActivityType.smoke.color,
//                        lineWidth: viewModel.showSmoke ? 3 : 0
//                    )
//            )
//            .animation(.easeInOut, value: viewModel.showSmoke)
        }
    }
    
    struct DateFilter: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
//            Text(viewModel.showDate.description)
//                .foregroundColor(.white)
            Button(action: {
                viewModel.showSmoke = false
                viewModel.showDate.toggle()
                viewModel.showPhoto = false
                viewModel.showTrain = false
                viewModel.showUnknown = false
                
                if viewModel.showDate {
                    Firebase.shared.startPostActivityListener(activity: .date)
                } else {
                    viewModel.startPostListenerForMode()
                }
            }) {
                Label(viewModel.showDate ? "hide date" : "show date",
                      systemImage: ActivityType.date.icon)
            }
            .tint(ActivityType.date.color)
            .buttonStyle(.glassProminent)
        }
    }
    
    struct PhotographyFilter: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
            Button(action: {
                viewModel.showSmoke = false
                viewModel.showDate = false
                viewModel.showPhoto.toggle()
                viewModel.showTrain = false
                viewModel.showUnknown = false
                
                if viewModel.showPhoto {
                    Firebase.shared.startPostActivityListener(activity: .photography)
                } else {
                    viewModel.startPostListenerForMode()
                }
            }) {
                Label(viewModel.showPhoto ? "hide photo" : "show photo",
                      systemImage: ActivityType.photography.icon)
            }
            .tint(ActivityType.photography.color)
            .buttonStyle(.glassProminent)
        }
    }
    
    struct TrainstationFilter: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
            Button(action: {
                viewModel.showSmoke = false
                viewModel.showDate = false
                viewModel.showPhoto = false
                viewModel.showTrain.toggle()
                viewModel.showUnknown = false
                
                if viewModel.showTrain {
                    Firebase.shared.startPostActivityListener(activity: .trainStation)
                } else {
                    viewModel.startPostListenerForMode()
                }
            }) {
                Label(viewModel.showTrain ? "hide train" : "show train",
                      systemImage: ActivityType.trainStation.icon)
            }
            .tint(ActivityType.trainStation.color)
            .buttonStyle(.glassProminent)
        }
    }
    
    struct UnknownFilter: View {
        @ObservedObject var viewModel: ButtonsViewModel
        var body: some View {
            Button(action: {
                viewModel.showSmoke = false
                viewModel.showDate = false
                viewModel.showPhoto = false
                viewModel.showTrain = false
                viewModel.showUnknown.toggle()
                
                if viewModel.showUnknown {
                    Firebase.shared.startPostActivityListener(activity: .unknown)
                } else {
                    viewModel.startPostListenerForMode()
                }
            }) {
                Label(viewModel.showUnknown ? "hide unknown" : "show unknown",
                      systemImage: ActivityType.unknown.icon)
                
            }
            .tint(ActivityType.unknown.color)
            .buttonStyle(.glassProminent)
        }
    }
}

extension Buttons {
    
    class ButtonsViewModel: ObservableObject {
        @Published var profileToggle: Bool = false
        @Published var showOnlyBookmarked: Bool = false
        
        @Published var showSmoke: Bool = false
        @Published var showDate: Bool = false
        @Published var showPhoto: Bool = false
        @Published var showTrain: Bool = false
        @Published var showUnknown: Bool = false
        
        func startPostListenerForMode() {
            if !profileToggle {
                Firebase.shared.startPostListener()
            } else if showOnlyBookmarked {
                Firebase.shared.startPostListener()
            } else {
                Firebase.shared.startUserPostListener(userId: Firebase.shared.getCurrentUserID())
            }
        }
    }
    
}
