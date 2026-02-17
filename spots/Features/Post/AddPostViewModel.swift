//
//  AddPostViewModel.swift
//  spots
//
//  Created by Aiden Gage on 2/3/26.
//
import SwiftUI
import MapKit

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

extension AddPostView {
    enum KeyboardField {
        case title
        case comment
        case address
        case latitude
        case longitude
    }
    
    enum ActivityType: CaseIterable, Identifiable {
        case smoke
        case date
        case photography
        case trainStation
        
        var id: Self { self }
        
        var displayActivity: String {
            switch self {
                case .smoke: return "Smoke"
                case .date: return "Date"
                case .photography: return "Photography"
                case .trainStation: return "Train Station"
            }
        }
    }
    
    @Observable class ViewModel {
        var centerLat: Double = 0
        var centerLong: Double = 0
        var title: String = ""
        var comment: String = ""
        var address: String = ""
        var rating: Decimal = 0.0
        var ratingCount: Int = 0
//        var selectedActivty: String = "Smoke"
        var selectedActivity: ActivityType = .smoke
        
        var imageURLs: [String] = []
        var imageData: [Data] = []
        var imageUUIDs: [String] = []
        var images: [UIImage] = []
    }
    
    // all for reverse geocoding to get the nearest address to the coordinates
    // saving place information in place object/struct
    struct Place {
        let lat: Double
        let long: Double
        let name: String?
        let address: String
        
        init(from mapItem: MKMapItem) {
            self.lat = mapItem.location.coordinate.latitude
            self.long = mapItem.location.coordinate.longitude
            self.name = mapItem.name
            // changed fullAddress to shortAddress temporarily to avoid double names
            // need to work on how this shows up, want to show the actual address from the full address and the name specifically
            self.address = mapItem.address?.shortAddress ?? "Unknown Address"
        }
    }
    
    struct ReverseGeocoding {
        // gets address from coordinates
        func nearestAddress(location: CLLocation) async throws -> Place? {
            if let request = MKReverseGeocodingRequest(location: location) {
                let mapItems = try await request.mapItems
                return mapItems.first.map(Place.init)
            }
            return nil
        }
    }
    
    func addTapGestureToDismissKeyboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
            return
        }
        
        let tapGesture = UITapGestureRecognizer(target: UIApplication.shared, action: #selector( UIApplication.dismissKeyboard ))
        tapGesture.cancelsTouchesInView = false  // This is KEY - lets other gestures still work
        window.addGestureRecognizer(tapGesture)
    }
    
    
}

extension UIApplication {
    @objc func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
