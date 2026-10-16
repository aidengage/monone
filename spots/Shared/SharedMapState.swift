//
//  SharedMapData.swift
//  spots
//
//  Created by Aiden Gage on 10/15/26.
//

import SwiftUI
import MapKit

final class SharedMapState: NSObject, MKMapViewDelegate {
    static let shared = SharedMapState()
    
    var cameraPosition: MapCameraPosition = .automatic
    private var oldCameraPosition: MapCameraPosition?
    private var rotationTimer: AnyCancellable?
    var rotation: Bool = false

    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.showsCompass = true
        map.isRotateEnabled = true
        
        return map
    }()
    
    var onRegionChanged: ((CLLocationCoordinate2D) -> Void)?
    var onAnnotationTapped: ((String) -> Void)?
    
    private override init() {
        super.init()
        mapView.delegate = self
    }
    
    func applyStyle(_ setting: MapStyleSetting) {
        switch setting {
        case .standard:
            mapView.mapType = .standard; mapView.pointOfInterestFilter = .includingAll
        case .hybrid:
            mapView.mapType = .hybrid;   mapView.pointOfInterestFilter = .excludingAll
        case .satellite,
             .experimental:
            mapView.mapType = .satellite
        }
    }
    
    func zoomOnPost(_ post: Post) {
        stopRotation()
        let camera = MKMapCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude),
            fromDistance: 600,
            pitch: 65,
            heading: 0
        )
        mapView.setCamera(camera, animated: true)
        startRotation(around: camera.centerCoordinate, distance: 600)
    }

    func exitPost() {
        stopRotation()
        isViewingPost = false
        guard let savedCamera = oldCameraPosition else { return }
        oldCameraPosition = nil
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = savedCamera
//                print("new/old camera position: \(cameraPosition)")
        }
            
    }

    
    func cameraZoomOnPost(post: Post) {
        if !isViewingPost {
            if let last = lastKnownCamera {
                oldCameraPosition = .camera(last)
            } else {
                oldCameraPosition = cameraPosition
            }
//                print("saved cam pos: \(cameraPosition)")
        }
        isViewingPost = true
        let targetLocation = CLLocationCoordinate2D(latitude: post.latitude, longitude: post.longitude)
        stopRotation()
        let camera = MKMapCamera(
            centerCoordinate: targetLocation, fromDistance: 600, heading: 0, pitch: 65
        )
//            let zoomLevel = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
//            let region = MKCoordinateRegion(center: targetLocation, span: zoomLevel)
//        cameraPosition = .region(region)
        
        // hardcoded offset camera zoom that barely works
//            let offsetCenter = CLLocationCoordinate2D(latitude: post.latitude - 0.0035, longitude: post.longitude)
//            let offsetRegion = MKCoordinateRegion(center: offsetCenter, span: zoomLevel)
//            cameraPosition = .region(offsetRegion)
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .camera(camera)
//                cameraPosition = .region(MKCoordinateRegion(center: camera.centerCoordinate, span: zoomLevel))
        }
//        return postView
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.startRotation(around: targetLocation)
        }
    }

    
    func startRotation(around coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) {
        rotationTimer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.currentHeading = (self.currentHeading + 0.3)
                    .truncatingRemainder(dividingBy: 360)
                let camera = MKMapCamera(
                    lookingAtCenter: coordinate,
                    fromDistance: distance,
                    pitch: 65,
                    heading: self.currentHeading
                )
                self.mapView.setCamera(camera, animated: false)
            }.store(in: &tokens)
    }

    func stopRotation() {
        rotation = false
        rotationTimer?.cancel()
        rotationTimer = nil
    }

}
