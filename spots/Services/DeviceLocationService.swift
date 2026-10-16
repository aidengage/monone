//
//  DeviceLocationService.swift
//  spots
//
//  Created by Minahil Khan on 1/18/26.
//
import CoreLocation
import Combine

//class is going to conform to Obsevable Object so we can inform Swift UI of any updates to our publisher.
class DeviceLocationService: NSObject, CLLocationManagerDelegate, ObservableObject{
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    private override init(){
        super.init()
    }
    static let shared = DeviceLocationService()
    
    //    the location manager is the object actually responsible for recieving location updates. Making it lazy so that we can modif the manager as we create it.
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    //implement delegate methods
    //    1. handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //returns an array of locations but we will only get the last one.
        guard let location = locations.last else {return}
        //pass the location coordinates through the publisher
        coordinatesPublisher.send(location.coordinate)
    }
    //    2. in case of errors
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinatesPublisher.send(completion: .failure(error))
    }
    //    3. Request Permission
    func requestLocationUpdates(){
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation( )
        default:
//      could just break here but we are going to create a publisher that handles this for us.
            deniedLocationAccessPublisher.send()
        }
    }
    
    //idk why i even need this one. what...
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case.authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
            deniedLocationAccessPublisher.send()
        }
    }
    }

