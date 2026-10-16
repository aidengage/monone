//
//  RefineLocationView.swift
//  spots
//
//  Created by Aiden Gage on 6/1/26.
//

import SwiftUI
import MapKit

struct RefineLocationPickerView: View {
    private let mapWidth: CGFloat = .infinity
    @State private var mapHeight: CGFloat = 200
    private let cornerRadius: CGFloat = 10
    
    @Binding var lat: Double
    @Binding var lon: Double
    
    @State private var region: MKCoordinateRegion
    @State private var isDragging = false
    
    @State private var position: MapCameraPosition
    @State private var oldPosition: MapCameraPosition? = nil
    
    var coordinateContinuation : AsyncStream<CLLocationCoordinate2D>.Continuation?
//    lazy var coordinateStream: AsyncStream<CLLocationCoordinate2D> = {
//        AsyncStream { continuation in
//            coordinateContinuation = continuation
//        }
//    }()
    
    func updateCoordinate(lat: Double, lng: Double) {
        coordinateContinuation?.yield(CLLocationCoordinate2D(latitude: lat, longitude: lng))
    }
    
    func resetUser() {
        
    }
    
    init(lat: Binding<Double>, lon: Binding<Double>) {
        self._lat = lat
        self._lon = lon
        self._region = State(initialValue: MKCoordinateRegion(
            center: .init(latitude: lat.wrappedValue, longitude: lon.wrappedValue),
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        ))
        self._position = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat.wrappedValue, longitude: lon.wrappedValue),
            span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
        )))
    }
    
    var body: some View {
        ZStack {
            Map(position: $position)
            
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            if !isDragging {
                                isDragging = true
                                mapHeight = 300
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            mapHeight = 200
                        }
                )
                
                .frame(maxWidth: mapWidth, minHeight: mapHeight, maxHeight: mapHeight)
                // can use .continuous but maxxes out the requests
                .onMapCameraChange(frequency: .onEnd) { mapCameraUpdateContext in
//                    print("coords: \(mapCameraUpdateContext.camera.centerCoordinate.latitude), \(mapCameraUpdateContext.camera.centerCoordinate.longitude)")
                    
                    if oldPosition == nil {
                        oldPosition = position
                    }
                    self.lat = mapCameraUpdateContext.camera.centerCoordinate.latitude
                    self.lon = mapCameraUpdateContext.camera.centerCoordinate.longitude
                }
            
            
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().fill(.white).frame(width: 9, height: 9))
                        .shadow(radius: 4)
                    
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        .frame(width: 48, height: 48)
                        .scaleEffect(isDragging ? 1 : 0.2)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
            }
        
            VStack {
                Spacer()
                Button(action: {
//                    print("reseting...")
                    if let original = oldPosition {
                        position = original
                        oldPosition = nil
                    }
                }) {
                    
                    Label("reset", systemImage: "arrow.2.circlepath")
                        
                }
                .buttonStyle(.glass)
                .font(.caption2)
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .padding(.bottom, 8)
            }
        }

        
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(.separator, lineWidth: 0.5))
    }
}
