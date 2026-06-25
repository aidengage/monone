//
//  VerticalDropdownToolbar.swift
//  spots
//
//  Created by Aiden Gage on 3/23/26.
//

import SwiftUI

struct VerticalDropdownToolbar: View {
    @State var dropdownToggle: Bool = false
    @ObservedObject var viewModel: ButtonsViewModel
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if viewModel.showAll {
                    ProfileButton(viewModel: viewModel)
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.circle)
                    
                    if viewModel.profileToggle {
                        BookmarkButton(viewModel: viewModel)
                        AccountButton(viewModel: viewModel, path: $path)
                        LogoutButton()
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
