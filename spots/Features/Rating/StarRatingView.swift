//
//  StarRatingView.swift
//  spots
//
//  Created by Aiden Gage on 1/16/26.
//

import SwiftUI

public struct RateSpotView: View {
    let post: Post
    @State var rating: Decimal = 0
    @State var comment: String = ""
    
    public var body: some View {
        VStack( spacing: 16) {
            HStack {
                StarRatingViewDynamic(rating: $rating, numStars: 5)
                Button(action: {
                    Task {
                        if Firebase.shared.getCurrentUserID() != "" {
                            await Firebase.shared.addRatingToPost(postOwner: post.userId, postId: post.id, userId: Firebase.shared.getCurrentUserID(), rating: rating, comment: comment)
                        } else {
                            print("please login")
                        }
                    }
                    
                    
                }) {
                    Label("Rate Spot!", systemImage: "heart.fill")
                        .buttonStyle(.glassProminent)
                }
            }
            TextField("Comment here...", text: $comment, axis: .vertical)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

public struct StarRatingViewDynamic: View {
    @Binding var rating: Decimal
    var numStars: Int = 5
    var starColor: Color
    var backgroundColor: Color
    
    public init(rating: Binding<Decimal>, numStars: Int, starColor: Color = .red, backgroundColor: Color = .gray) {
        self._rating = rating
        self.numStars = numStars
        self.backgroundColor = backgroundColor
        self.starColor = starColor
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                BackgroundStars(numStars: numStars, color: backgroundColor)
                ForegroundStars(numStars: numStars, rating: rating, color: starColor)
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let totalWidth = CGFloat(geo.size.width)
                    let x = min(max(value.location.x, 0), totalWidth)
                    let percent = x / totalWidth
                    let rawRating = Double(self.numStars) * percent
                    let snappedRating = round(rawRating * 10) / 10
                    
//                    self.rating = Decimal(Double(self.numStars) * percent) as Decimal
                    self.rating = Decimal(snappedRating)
                }
            )
        }
//        .frame(height: 50)
        .aspectRatio(CGFloat(numStars), contentMode: .fit)
    }
}

public struct StarRatingViewStatic: View {
    var rating: Decimal
    var numStars: Int = 5
    var starColor: Color
    var backgroundColor: Color
    
    public init(rating: Decimal, numStars: Int, starColor: Color = .red, backgroundColor: Color = .gray) {
        self.rating = rating
        self.numStars = numStars
        self.backgroundColor = backgroundColor
        self.starColor = starColor
    }
    
    public var body: some View {
        ZStack {
            BackgroundStars(numStars: numStars, color: backgroundColor)
            ForegroundStars(numStars: numStars, rating: rating, color: starColor)
        }
        .aspectRatio(CGFloat(numStars), contentMode: .fit)
    }
}


struct RatingStar: View {
    var rating: CGFloat
    var color: Color
    var index: Int
    
    var maskRatio: CGFloat {
        let mask = rating - CGFloat(index)
        
        switch mask {
            case 1...: return 1
            case ..<0: return 0
            default: return mask
        }
    }
    
    init(rating: Decimal, color: Color, index: Int) {
        self.rating = CGFloat(Double(rating.description) ?? 0)
        self.color = color
        self.index = index
    }
    
    var body: some View {
        GeometryReader { star in
            Image(systemName: "star.fill")
                .resizable()
//                .aspectRatio(contentMode: .fit)
                .scaledToFit()
                .foregroundColor(self.color)
                .mask(
                    Rectangle()
                        .size(
                            width: star.size.width * self.maskRatio,
                            height: star.size.height
                        )
                    
                )
//                .aspectRatio(contentMode: .fit)
            
        }
    }
}

private struct BackgroundStars: View {
    var color: Color
    var numStars: Int

    init(numStars: Int, color: Color) {
        self.numStars = numStars
        self.color = color
    }

    var body: some View {
        HStack {
            ForEach(0..<numStars) { index in
                StarImage()
                    .foregroundColor(color)
            }
        }
    }
}

private struct ForegroundStars: View {
    var rating: Decimal
    var color: Color
    var numStars: Int

    init(numStars: Int, rating: Decimal, color: Color) {
        self.numStars = numStars
        self.rating = rating
        self.color = color
    }
    
    var body: some View {
        HStack {
            ForEach(0..<numStars) { index in
                RatingStar(rating: self.rating, color: self.color, index: index)
            }
        }
    }
}

private struct StarImage: View {
    var body: some View {
        GeometryReader { geo in
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}
