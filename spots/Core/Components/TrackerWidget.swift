//
//  TrackerWidget.swift
//  spots
//
//  Created by Aiden Gage on 7/6/26.
//

import SwiftUI
import SwiftData

#Preview {
    
    @Previewable @Environment(\.tracker) var tracker
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    let container = try! ModelContainer(for: ItemData.self, configurations: config)
    
    let jointItem = ItemData(id: UUID().uuidString, name: "joint", icon: "leaf.circle.fill", colorHex: "red", /*lastSyncedAt = nil,*/ sortOrder: 0, incrementStep: 1.0, isPinned: true, trackingType: .daily)
    let bowlItem = ItemData(id: UUID().uuidString, name: "bowl", icon: "heat.waves.circle.fill", colorHex: "purple", /*lastSyncedAt = nil,*/ sortOrder: 0, incrementStep: 1.0, isPinned: true, trackingType: .daily)
//    
    let items: [ItemData] = [jointItem, bowlItem]
    
    tracker.addItemsToContext(items: items, context: container.mainContext)
//    tracker.syncItems(context: container)
//    container.mainContext.insert(jointItem)
//    container.mainContext.insert(bowlItem)
        
    
    
    
    return TrackerWidget()
        .modelContainer(container)
//        .task {
//            await tracker.syncItems(context: container.mainContext)
//        }
}

struct TrackerWidget: View {
    @Query(filter: #Predicate<ItemData> { $0.isPinned == true })
    private var pinnedItems: [ItemData]
    @State private var showFullTracker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(pinnedItems.prefix(2)) { item in
                TrackerWidgetRow(item: item)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 3)
        .onTapGesture {
            showFullTracker.toggle()
        }
        .sheet(isPresented: $showFullTracker) {
            TrackerListView()
        }
    }
}

struct TrackerWidgetRow: View {
    @Bindable var item: ItemData
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: item.icon)
//                .foregroundStyle(.background)
            
            Text(item.name)
                .font(.caption)
            
            Spacer()
                .frame(width: 15)
            
            Button {
                item.decrement(context: context)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.secondary)
            }
            
            Text(item.displayCount.trackerDisplay)
                .font(.headline)
                .frame(minWidth: 28)
            
            Button {
                item.increment(context: context)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TrackerListView: View {
    // 1. Fetch all items sorted by your sortOrder property
    @Query(sort: \ItemData.sortOrder) private var allItems: [ItemData]
    
    // 2. Grab the context to handle item deletions and creations
    @Environment(\.modelContext) private var context
    
    // 3. For dismissing the sheet view
    @Environment(\.dismiss) private var dismiss
    
    // 4. Local state to show an alert or sheet for creating a new item
    @State private var showAddItemAlert = false
    @State private var newItemName = ""
    
    // Split items into pinned and unpinned computed properties for clean UI separation
    private var pinnedItems: [ItemData] {
        allItems.filter { $0.isPinned }
    }
    
    private var unpinnedItems: [ItemData] {
        allItems.filter { !$0.isPinned }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Section A: Pinned Trackers
                if !pinnedItems.isEmpty {
                    Section("Pinned Tasks") {
                        ForEach(pinnedItems) { item in
                            TrackerRowContainer(item: item)
                        }
                        .onDelete { indexSet in deleteItems(from: pinnedItems, at: indexSet) }
                    }
                }
                
                // Section B: Regular Trackers
                Section("All Trackers") {
                    if unpinnedItems.isEmpty && pinnedItems.isEmpty {
                        ContentUnavailableView("No Trackers",
                                               systemImage: "waveform.path.ecg",
                                               description: Text("Tap the '+' button to start tracking items."))
                    } else {
                        ForEach(unpinnedItems) { item in
                            TrackerRowContainer(item: item)
                        }
                        .onDelete { indexSet in deleteItems(from: unpinnedItems, at: indexSet) }
                    }
                }
            }
            .navigationTitle("My Trackers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddItemAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Simple alert text box to add a new item quickly
            .alert("New Tracker", isPresented: $showAddItemAlert) {
                TextField("Tracker Name", text: $newItemName)
                Button("Cancel", role: .cancel) { newItemName = "" }
                Button("Create") { createNewTracker() }
            } message: {
                Text("Enter a name for the metric you want to track.")
            }
        }
    }
    
    // Helper to safely delete items using native row swipes
    private func deleteItems(from sourceList: [ItemData], at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = sourceList[index]
            context.delete(itemToDelete)
        }
        // SwiftData auto-saves, but forcing it keeps UI state rigid
        try? context.save()
    }
    
    // Quick helper to insert a new ItemData instance into your context
    private func createNewTracker() {
        guard !newItemName.isEmpty else { return }
        
        let newItem = ItemData(
            id: UUID().uuidString,
            name: newItemName,
            icon: "checkmark.seal.fill",
            colorHex: ".green", // Default green color hex
            sortOrder: allItems.count,
            isPinned: false
        )
        
        context.insert(newItem)
        try? context.save()
        newItemName = ""
    }
}

// A lightweight container row that wraps your existing TrackerWidgetRow
// and adds a contextual swipe option to pin/unpin items directly.
struct TrackerRowContainer: View {
    @Bindable var item: ItemData
    
    var body: some View {
        TrackerWidgetRow(item: item)
            .padding(.vertical, 4)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    item.isPinned.toggle()
                } label: {
                    Label(item.isPinned ? "Unpin" : "Pin",
                          systemImage: item.isPinned ? "pin.slash.fill" : "pin.fill")
                }
                .tint(item.isPinned ? .gray : .orange)
            }
    }
}
