//
//  PersistentSettings.swift
//  spots
//
//  Created by Aiden Gage on 6/5/26.
//
//  https://holyswift.app/using-userdefaults-to-persist-in-swiftui/

import SwiftUI

enum MapStyleSetting: String, CaseIterable, Identifiable {
    case standard
    case hybrid
    case satellite
    case experimental
    
    var id: Self { self }
}

extension String {
    static var settingsMapStyleKey: String { ".settingsMapStyle"}
}

struct SettingsView: View {
    @AppStorage(.settingsMapStyleKey) private var mapStyle: MapStyleSetting = .standard
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Map Style")) {
                    Picker("Preferred map style...", selection: $mapStyle) {
                        ForEach(MapStyleSetting.allCases) { style in
                            Text(style.rawValue.capitalized)
                                .tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
}
