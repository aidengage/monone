//
//  MapViewModel.swift
//  spots
//
//  Created by Aiden Gage on 1/31/26.
//

import SwiftUI
import MapKit
import Combine

import FirebaseCore
import FirebaseFirestore


extension MapView {
// observable makes sure VieModel's stored properties can automatically publish changes so SwiftUI views can react
    class ViewModel: ObservableObject {
        var hasValidLocation = false
        var hasCenteredOnUser = false
        //*what is this?
        var observersSetUp = false

        @Published var selectedPost: Post?
        var selectedPostID: String?
        
        @Published var selectedMapStyleType: MapStyleType = .standard
        var currentMapStyle: MapStyle {
            switch selectedMapStyleType {
            case .standard:
                return .standard
//            case .imagery:
//                return .imagery(elevation: .realistic)
            case .hybrid:
                return .hybrid(elevation: .realistic)
            }
        }
        var currentMapIcon: String {
            switch selectedMapStyleType {
            case .standard:
                return "map"
            case .hybrid:
                return "globe"
//            case .imagery:
//                return "bonjour"
            }
        }
        
        var coordinates: (lat: Double, lon: Double) = (0,0)
        var centerLat: Double = 0
        var centerLong: Double = 0
        
        var deviceLocationService = DeviceLocationService.shared
    //*what do we need this for? --> to store the user location perhaps
        var tokens: Set<AnyCancellable> = []
        
        var path: NavigationPath = NavigationPath()
        
    //*why is camera position hardcoded in?
        @Published var cameraPosition: MapCameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 38.25, longitude: -85.75),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
        
        func update(centerLat: Double) {
            self.centerLat = centerLat
        }
        
        func update(centerLong: Double) {
            self.centerLong = centerLong
        }
        
        func cameraZoomOnPost(post: Post) {
            let targetLocation = CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)
            let zoomLevel = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let region = MKCoordinateRegion(center: targetLocation, span: zoomLevel)
    //        cameraPosition = .region(region)
            
            // hardcoded offset camera zoom that barely works
            let offsetCenter = CLLocationCoordinate2D(latitude: post.latitude - 0.0035, longitude: post.longitude)
            let offsetRegion = MKCoordinateRegion(center: offsetCenter, span: zoomLevel)
            cameraPosition = .region(offsetRegion)
    //        return postView
        }
        
        //using publisher provided by deviceLocationService
        func observeCoordinateUpdates(){
            deviceLocationService.coordinatesPublisher
                .receive(on: DispatchQueue.main)
                .sink{ completion in
                    if case .failure(let error) = completion {
                        print(error)
                    }
                } receiveValue: { coordinates in
                    // Update coordinates and mark as valid
                    self.coordinates = (coordinates.latitude, coordinates.longitude)
                    self.hasValidLocation = true
                    
                    // Center map on user's location the first time we get it
                    if !self.hasCenteredOnUser {
                        self.cameraPosition = .region(
                            MKCoordinateRegion(
                                center: coordinates,
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            )
                        )
                        self.hasCenteredOnUser = true
                    }
                    
                }
                .store(in: &tokens)
        }
        
        func observeLocationAccessDenied(){
            deviceLocationService.deniedLocationAccessPublisher
                .receive(on: DispatchQueue.main)
                .sink{
                    print("location denied")
                }
                .store(in: &tokens)
        }
        
        //**lowkey why do we even need this function?
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
        }
    }
}
