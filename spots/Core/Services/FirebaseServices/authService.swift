//
//  authService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import FirebaseAuth

protocol authServiceProtocol {
    
}

@Observable
class authService: authServiceProtocol {
    private let auth = Auth.auth()
    
    func getAuth() -> Auth {
        return auth
    }
    
    func getAuthStatus() -> Bool {
        return auth.currentUser != nil
    }
}
