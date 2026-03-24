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
    
    var body: some View {
        VStack {

            Buttons.ProfileButton(viewModel: viewModel)
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
            
            if viewModel.profileToggle {
                Buttons.BookmarkButton(viewModel: viewModel)
                Buttons.LogoutButton()
            }
        }
        .padding(.leading, 15)
    }
}

#Preview {
    VerticalDropdownToolbar(viewModel: Buttons.ButtonsViewModel())
}
