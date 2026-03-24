//
//  VerticalDropdownToolbar.swift
//  spots
//
//  Created by Aiden Gage on 3/23/26.
//

import SwiftUI

struct VerticalDropdownToolbar: View {
    @State var mainToggle: Bool = false
    
    var body: some View {

        ZStack {
            VStack {
                Button(action: {
                    print("vertical dropdown toolbar")
                    withAnimation(.easeInOut(duration: 0.2)) {
                        mainToggle.toggle()
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.largeTitle)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                
                if mainToggle {
                    Button(action: {
                        print("new button spawn")
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
//                            .padding(10)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .tint(.red)
                    .transition(.opacity)
                    
                    Button(action: {
                        print("third button whaaaat")
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.largeTitle)
//                            .padding(10)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .tint(.orange)
                    .transition(.opacity)
                }
            }
            .padding(.leading, 10)
//            .ignoresSafeArea(edges: .top)
//            .safeAreaPadding(.top, 20)
//            .safeAreaInset(edge: .top) {
//                Text("top edge !")
//            }
        }
        
        
        
        
    }
}

#Preview {
    VerticalDropdownToolbar()
}
