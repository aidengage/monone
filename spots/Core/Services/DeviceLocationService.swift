//
//  DeviceLocationService.swift
//  spots
//
//  Created by Minahil Khan on 1/18/26.
//
import CoreLocation
import SwiftUI
//import Combine

protocol locationProtocol {
    var location: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var error: Error? { get }
    var isAccessDenied: Bool { get }
    
    func requestLocationUpdates()
    func stopLocationUpdates()
}

//class is going to conform to Obsevable Object so we can inform Swift UI of any updates to our publisher.
@Observable
@MainActor
class DeviceLocationService: NSObject, CLLocationManagerDelegate, locationProtocol {
    
    
//    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
//    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    static let shared = DeviceLocationService()
    private(set) var location: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var error: Error?
    private(set) var isAccessDenied = false
    private let locationManager: CLLocationManager
    
    //    the location manager is the object actually responsible for recieving location updates. Making it lazy so that we can modif the manager as we create it.
//    private lazy var locationManager: CLLocationManager = {
//        let manager = CLLocationManager()
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.delegate = self
//        return manager
//    }()
    
    override init() {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager = manager
        super.init()
        manager.delegate = self
    }
    
//    override init(){
//        super.init()
//    }
    
    //implement delegate methods
    //    1. handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //returns an array of locations but we will only get the last one.
        guard let location = locations.last else {return}
        //pass the location coordinates through the publisher
        self.location = location
    }
    //    2. in case of errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    //    3. Request Permission
    func requestLocationUpdates(){
        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isAccessDenied = false
            locationManager.startUpdatingLocation()
        default:
//      could just break here but we are going to create a publisher that handles this for us.
            isAccessDenied = true
        }
    }
    
    //idk why i even need this one. what...
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAccessDenied = false
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            isAccessDenied = true
            locationManager.stopUpdatingLocation()
        default:
            break // .notDetermined
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

