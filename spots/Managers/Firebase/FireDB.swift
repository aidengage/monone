//
//  FireDB.swift
//  spots
//
//  Created by Aiden Gage on 1/20/26.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

final class FireMod {
    static let shared = FireMod()
    
    let fs = Firestore.firestore()
    let auth = FireAuth()
    let storage = FireStorage()
    
    
//    init() {
//        let app = FirebaseApp.app()!
//    }
}
