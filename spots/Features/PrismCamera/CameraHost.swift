//
//  CameraHost.swift
//  spots
//
//  Created by Aiden Gage on 10/11/26.
//

import SwiftUI
import UIKit

struct CameraHost: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> StudioViewController {
        StudioViewController()
    }

    func updateUIViewController(_ vc: StudioViewController, context: Context) {}

    
    
}
