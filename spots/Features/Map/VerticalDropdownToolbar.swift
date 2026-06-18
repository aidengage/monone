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

                    Buttons.FriendsMapButton(viewModel: viewModel)
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)

                    if viewModel.profileToggle {
                        Buttons.BookmarkButton(viewModel: viewModel)
                        Buttons.AccountButton(viewModel: viewModel, path: $path)
                        Buttons.LogoutButton()
                    }
                }
            }
        }
        .padding(.leading, 15)
    }
}

//#Preview {
//    VerticalDropdownToolbar(viewModel: Buttons.ButtonsViewModel())
//}
