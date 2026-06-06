//
//  VerticalDropdownToolbar.swift
//  spots
//
//  Created by Aiden Gage on 3/23/26.
//

import SwiftUI

struct VerticalDropdownToolbar: View {
    @State var dropdownToggle: Bool = false
    @ObservedObject var viewModel: Buttons.ButtonsViewModel
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
        VStack {
            if viewModel.showAll {
                Buttons.ProfileButton(viewModel: viewModel)
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                
                if viewModel.profileToggle {
                    Buttons.BookmarkButton(viewModel: viewModel)
                    Buttons.LogoutButton()
                    
                    
                        Button(action: {
                            viewModel.showFollowinger.toggle()
                        }) {
                            Image(systemName: "person.text.rectangle")
                                .font(.title)
                                .padding(1)
                                
                        }
                        .tint(.purple)
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)
                        .navigationDestination(isPresented: $viewModel.showFollowinger) {
                            AccountView(path: $path)
                        }
                    }
//                    NavigationLink {
//                        AccountView()
//                    } label: {
//                        Image(systemName: "person.text.rectangle")
//                            .font(.title)
//                            .padding(1)
//                    }
//                    .buttonStyle(.glassProminent)
//                    .buttonBorderShape(.circle)
                }
            }
        }
        .padding(.leading, 15)
    }
}

//#Preview {
//    VerticalDropdownToolbar(viewModel: Buttons.ButtonsViewModel())
//}
