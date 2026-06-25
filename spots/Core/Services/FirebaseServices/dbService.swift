//
//  dbService.swift
//  spots
//
//  Created by Aiden Gage on 6/25/26.
//

import SwiftUI
import FirebaseFirestore

protocol dbServiceProtocol {
    func getDB() -> Firestore
}

@Observable
class dbService: dbServiceProtocol {
    private let db = Firestore.firestore()
    
    func getDB() -> Firestore {
        return db
    }
}
