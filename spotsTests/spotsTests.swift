//
//  spotsTests.swift
//  spotsTests
//
//  Created by Aiden Gage on 2/17/26.
//

import Testing
import SwiftUI
@testable import spots

struct spotsTests {

    struct PostTests {
        @Test func postName() {
            let post = Post(id: UUID().uuidString, userId: UUID().uuidString, images: [], name: "Apple Park", address: "1 Apple Park Way, Cupertino, CA 95014", ratingCount: 0, latitude: 0, longitude: 0, avgRating: 0, selectedActivity: Post.ActivityType.photography.displayActivity)
            #expect(post.name == "Apple Park")
        }
    }

}
