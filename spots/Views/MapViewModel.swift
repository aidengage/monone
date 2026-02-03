//
//  MapViewModel.swift
//  spots
//
//  Created by Aiden Gage on 1/31/26.
//

import SwiftUI
import MapKit
import Combine

extension MapView {
    @Observable
    class ViewModel {
        @State private var hasValidLocation = false
        @State private var hasCenteredOnUser = false
        @State private var observersSetUp = false
        
        @State private var posts: [PostMan] = []
        @State var selectedPost: PostMan? = nil
        
        @State var coordinates: (lat: Double, lon: Double) = (0,0)
        @State var centerLat: Double
        @State var centerLong: Double
        
        @StateObject var deviceLocationService = DeviceLocationService.shared
        @State var tokens: Set<AnyCancellable> = []
        
        @Binding var path: NavigationPath
        
        @State private var cameraPosition: MapCameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 38.25, longitude: -85.75),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
        
        init() {}
        
        func cameraZoomOnPost(post: PostMan) {
            let targetLocation = CLLocationCoordinate2D(latitude: post.coords.0, longitude: post.coords.1)
            let zoomLevel = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: targetLocation, span: zoomLevel)
    //        cameraPosition = .region(region)
            
            // hardcoded offset camera zoom that barely works
            let offsetCenter = CLLocationCoordinate2D(latitude: post.coords.0 - 0.006, longitude: post.coords.1)
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
                    if !hasCenteredOnUser {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: coordinates,
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            )
                        )
                        hasCenteredOnUser = true
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
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
        }
    }
}
