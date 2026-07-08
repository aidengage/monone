//
//  TrackerSyncService.swift
//  spots
//
//  Created by Aiden Gage on 7/6/26.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

protocol trackerProtocol {
    func seedDefaultTrackedItems(context: ModelContext)
    func addItemsToContext(items: [ItemData], context: ModelContext)
    func syncItems(context: ModelContext) async
    func syncSnapshots(context: ModelContext) async
    func restoreFromBackup(context: ModelContext) async throws
}

@Observable
@MainActor
class TrackerSyncService: trackerProtocol {
    private let authService: authServiceProtocol
    private let dbService: dbServiceProtocol
    
    init(authService: authServiceProtocol, dbService: dbServiceProtocol) {
        self.authService = authService
        self.dbService = dbService
    }
    
    func addItemsToContext(items: [ItemData], context: ModelContext) {
        let descriptor = FetchDescriptor<ItemData>()
        let existingItems = (try? context.fetch(descriptor)) ?? []

        for item in items {
            let alreadyExists = existingItems.contains { $0.name == item.name }

            if !alreadyExists {
                context.insert(item)
            }
            
        }
        try? context.save()
    }
    
    func seedDefaultTrackedItems(context: ModelContext) {
        let descriptor = FetchDescriptor<ItemData>()
        let existingItems = (try? context.fetch(descriptor)) ?? []
        
        let defaultItems = [
            ItemData(id: UUID().uuidString, name: "joint", icon: "leaf.circle.fill", colorHex: "red", sortOrder: 1, incrementStep: 1.0, isPinned: true, trackingType: .daily),
            ItemData(id: UUID().uuidString, name: "bowl", icon: "heat.waves.circle.fill", colorHex: "purple", sortOrder: 0, incrementStep: 0.5, isPinned: true, trackingType: .daily)
        ]
        
        for item in defaultItems {
            let alreadyExists = existingItems.contains { $0.name == item.name }

            if !alreadyExists {
                context.insert(item)
            }
        }
        
        try? context.save()
    }
    
    func syncItems(context: ModelContext) async {
        let descriptor = FetchDescriptor<ItemData>()
        guard let items = try? context.fetch(descriptor),
              let userId = try? authService.getCurrentUserID() else { return }
        
        let batch = dbService.getBatch()
        
        for item in items {
            let docRef = dbService.getStore().collection("users").document(userId)
                .collection("trackedItems").document(item.id)
            batch.setData([
                "name": item.name,
                "icon": item.icon,
                "colorHex": item.colorHex,
                "lastSyncedAt": Timestamp(date: item.lastSyncedAt ?? Date.now),
                "sortOrder": item.sortOrder,
                "isPinned": item.isPinned,
                
            ], forDocument: docRef)
        }
        
        try? await batch.commit()
    }
    
    // fresh install / new login stuff
    func restoreFromBackup(context: ModelContext) async throws {
        guard let userId = try? authService.getCurrentUserID() else { return }
        let snapshot = try await dbService.getStore().collection("users").document(userId)
            .collection("trackedItems").getDocuments()
        
        for doc in snapshot.documents {
            let data = doc.data()
            let item = ItemData(
                id: doc.documentID,
                name: data["name"] as? String ?? "",
                icon: data["icon"] as? String ?? "questionmark",
                colorHex: data["colorHex"] as? String ?? "#000000",
                sortOrder: data["sortOrder"] as? Int ?? 0,
                isPinned: data["isPinned"] as? Bool ?? false)
            
            if let timestamp = data["lastSyncedAt"] as? Timestamp {
                item.lastSyncedAt = timestamp.dateValue()
            }
            context.insert(item)
        }
    }
    
    func syncSnapshots(context: ModelContext) async {
        let descriptor = FetchDescriptor<DailySnapshot>(
            predicate: #Predicate { $0.isSynced == false }
        )
        guard let unsynced = try? context.fetch(descriptor),
              !unsynced.isEmpty,
              let userId = try? authService.getCurrentUserID() else { return }
        let batch = dbService.getBatch() // keep eye on this
        for snapshot in unsynced {
            let docRef = dbService.getStore().collection("users").document(userId)
                .collection("dailySnapshots").document(snapshot.id)
            batch.setData([
                "trackedItemId": snapshot.trackedItemId,
                "date": Timestamp(date: snapshot.date),
                "count": snapshot.count
                
            ], forDocument: docRef)
        }
        
        try? await batch.commit()
        unsynced.forEach { $0.isSynced = true }
        try? context.save()
    }
}
