//
//  VerticalDropdownToolbar.swift
//  spots
//
//  Created by Aiden Gage on 3/23/26.
//

import SwiftUI

struct VerticalDropdownToolbar: View {
    @Environment(\.buttonsViewModel) private var viewModel
    @Binding var path: NavigationPath
    @Environment(\.visible) private var visible
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if viewModel.showAll {
                    
                    if viewModel.profileToggle && visible.currState() {
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
