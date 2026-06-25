//
//  UserService.swift
//  spots
//
//  Created by Aiden Gage on 6/22/26.
//

import SwiftUI

@Observable
class UserService {
    var bookmarkedPostIds: [String] = []
    var followers: [String] = []
    var following: [String] = []
}
