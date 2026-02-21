//
//  CameraManager.swift
//  spots
//
//  Created by Aiden Gage on 2/21/26.
//

import SwiftUI
import AVFoundation

class CameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let deviceInput: AVCaptureDeviceInput?
    private let videoOutput: AVCaptureVideoDataOutput?
    private let systemPreferredCamera = AVCaptureDevice.default(for: .video)
    private let sessionQueue = DispatchQueue(label: "video.preview.session")
}
