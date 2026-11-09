//
//  CustomPostView.swift
//  spots
//
//  Created by Aiden Gage on 11/8/26.
//

import SwiftUI
import Kingfisher

struct PhotoCardTop: View {
    let urls: [String]  // Array of image URLs

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: .constant(0)) {  // Use @State if you want to track the selected tab
                ForEach(urls.indices, id: \.self) { index in
                    KFImage.url(URL(string: urls[index]))
                        .resizable()
                        .scaledToFill()
//                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct InfoCardBottom: View {    
    let icon: String          // Icon name (SF Symbols)
    let title: String         // Title of the info card
    let content: String       // Content to display
    let iconColor: Color      // Color for the icon

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
//                    .textSelectionEnabled()  // Allow text selection for copying
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

