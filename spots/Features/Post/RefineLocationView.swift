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
    private let mapHeight: CGFloat = 200
    private let cornerRadius: CGFloat = 10
    
    @Binding var lat: Double
    @Binding var lon: Double
    
    @State private var region: MKCoordinateRegion
    @State private var isDragging = false
    
    @State private var position: MapCameraPosition
    
    var coordinateContinuation : AsyncStream<CLLocationCoordinate2D>.Continuation?
//    lazy var coordinateStream: AsyncStream<CLLocationCoordinate2D> = {
//        AsyncStream { continuation in
//            coordinateContinuation = continuation
//        }
//    }()
    
    func updateCoordinate(lat: Double, lng: Double) {
        coordinateContinuation?.yield(CLLocationCoordinate2D(latitude: lat, longitude: lng))
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
            
                
                .frame(maxWidth: mapWidth, minHeight: mapHeight, maxHeight: mapHeight)
                // can use .continuous but maxxes out the requests
                .onMapCameraChange(frequency: .onEnd) { mapCameraUpdateContext in
                    print("coords: \(mapCameraUpdateContext.camera.centerCoordinate.latitude), \(mapCameraUpdateContext.camera.centerCoordinate.longitude)")
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
                        if isDragging {
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                .frame(width: 48, height: 48)
                        }
                    }
                }
//            .animation(.spring(response: 0.25), value: isDragging)
        
            if !isDragging {
                VStack {
                    Spacer()
                    Label("drag to refine", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.45), in: Capsule())
                        .padding(.bottom, 8)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { _ in isDragging = true }
                .onEnded { _ in isDragging = false }
        )
        
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(.separator, lineWidth: 0.5))
    }
}
