//
//  Item.swift
//  spots
//
//  Created by Aiden Gage on 7/6/26.
//

import SwiftUI
import SwiftData

enum TrackingType: String, Codable {
    case daily
//    case weekly
//    case monthly
//    case annually
    case lifetime
}

enum ItemType {
    case joint, one_hitter, bowl, bong, dab
    
    var displayName: String {
        switch self {
        case .joint: return "Joint"
        case .one_hitter: return "One Hitter"
        case .bowl: return "Bowl"
        case .bong: return "Bong"
        case .dab: return "Dab"
        }
    }
    
    var defaultIcon: String {
        switch self {
        case .joint: return "leaf.fill"
        case .one_hitter: return "circle.fill"
        case .bowl: return "smoke.fill"
        case .bong: return "drop.fill"
        case .dab: return "flame.fill"
        }
    }
    
    var defaultColorHex: String {
        switch self {
        case .joint: return "#4CAF50"
        case .one_hitter: return "#FF9800"
        case .bowl: return "#9C27B0"
        case .bong: return "#2196F3"
        case .dab: return "#F44336"
        }
    }
}

@Model
class ItemData {
    @Attribute(.unique) var id: String
    var name: String
    var icon: String
    var colorHex: String
    var lastSyncedAt: Date?
    var sortOrder: Int
    var incrementStep: Double
    var isPinned: Bool
    var trackingType: TrackingType
    
    @Relationship(deleteRule: .cascade) var snapshots: [DailySnapshot] = []
    
    init(id: String = UUID().uuidString, name: String, icon: String, colorHex: String, lastSyncedAt: Date? = nil, sortOrder: Int = 0, incrementStep: Double = 1.0, isPinned: Bool, trackingType: TrackingType = .daily) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.lastSyncedAt = lastSyncedAt
        self.sortOrder = sortOrder
        self.incrementStep = incrementStep
        self.isPinned = isPinned
        self.trackingType = trackingType
    }
    
    var color: Color {
        Color(colorHex)
    }
}

@Model
class DailySnapshot {
    @Attribute(.unique) var id: String
    var trackedItemId: String
    var date: Date
    var count: Double
    var isSynced: Bool = false
    
    init(id: String = UUID().uuidString, trackedItemId: String, date: Date, count: Double = 0.0) {
        self.id = id
        self.trackedItemId = trackedItemId
        self.date = Calendar.current.startOfDay(for: date)
        self.count = count
    }
    
}

struct ItemPreset: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let colorHex: String
}

enum ItemPresets {
    static let all: [ItemPreset] = [
        ItemPreset(name: "Joint", icon: "leaf.fill", colorHex: "#4CAF50"),
        ItemPreset(name: "One Hitter", icon: "circle.fill", colorHex: "#FF9800"),
        ItemPreset(name: "Bowl", icon: "smoke.fill", colorHex: "#9C27B0"),
        ItemPreset(name: "Bong", icon: "drop.fill", colorHex: "#2196F3"),
        ItemPreset(name: "Dab", icon: "flame.fill", colorHex: "#F44336")
    ]
}

//enum ItemType: String, Codable, CaseIterable {
//    case joint, one_hitter, bowl, bong, dab, kief
//    
//    var defaultIcon: String {
//}
