//
//  FireStorage.swift
//  spots
//
//  Created by Aiden Gage on 1/20/26.
//

import SwiftUI
import FirebaseCore
import FirebaseStorage

final class FireStorage {
    let storage: Storage
    
    init() {
        let app = FirebaseApp.app()!
        storage = Storage.storage(app: app)
    }
}
