//
//  CameraManager.swift
//  spots
//
//  Created by Aiden Gage on 2/21/26.
//
//  documentation by
//  https://www.createwithswift.com/camera-capture-setup-in-a-swiftui-app/

import SwiftUI
import AVFoundation
import CoreImage

class CameraManager: NSObject {
    // bunch of variables
    
    // an AVCaptureSession object that performs real-time capture and adds appropriate inputs and outputs
    private let captureSession = AVCaptureSession()
    // an AVCaptureDeviceInput that describes the media input from a capture device to a capture session
    private var deviceInput: AVCaptureDeviceInput?
    // an AVCaptureVideoDataOutput object used to have access to video frames for processing
    private var videoOutput: AVCaptureVideoDataOutput?
    // an AVCaptureDevice object represents the hardware or virtual capture device that can provide one or more streams of media of a particular type
    private let systemPreferredCamera = AVCaptureDevice.default(for: .video)
    // the queue on which the AVCaptureVideoDataOutputSampleBufferDelegate callbacks should be invoked. It is mandatory to use a serial dispatch queue to guarantee that video frames will be delivered in order
    private let sessionQueue = DispatchQueue(label: "video.preview.session")
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    private var addToPreviewStream: ((CGImage) -> Void)?
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    
    // In the CameraManager initializer, we are going to configure and start the AVCaptureSession at the same time. This could be handled in other ways, depending on your specific needs
    override init() {
        super.init()
        
        Task {
            await configureSession()
            await startSession()
        }
    }
    
    // The configureSession() function will be responsible for initializing all our properties and defining the buffer delegate
    private func configureSession() async {
        // Check user authorization, if the selected camera is available, and if can take the input through the AVCaptureDeviceInput object
        guard await isAuthorized,
              let systemPreferredCamera,
              let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
                else { return }
        
        // Start the configuration, marking the beginning of changes to the running capture session’s configuration
        captureSession.beginConfiguration()
        
        // At the end of the execution of the method commits the configuration to the running session
        defer {
            self.captureSession.commitConfiguration()
        }
        
        // better quality apparently
        captureSession.sessionPreset = .photo
        
        // Define the video output and set the Sample Buffer Delegate and the queue for invoking callbacks
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // Check if the input can be added to the capture session
        guard captureSession.canAddInput(deviceInput) else {
            print("unable to add device input to capture session")
            return
        }
        
        // Checking if the output can be added to the session
        guard captureSession.canAddOutput(videoOutput) else {
            print("unable to add video output to capture session")
            return
        }
        
        // Adds the input and the output to the AVCaptureSession
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
        
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
        
//        updateVideoOrientation()
        
        self.deviceInput = deviceInput
        self.videoOutput = videoOutput
    }
    
    private func updateVideoOrientation() {
        guard let videoOutput = videoOutput, let connection = videoOutput.connection(with: .video) else {
            return
        }
        
        if connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        
        if let device = deviceInput?.device, device.position == .front {
            connection.isVideoMirrored = true
        }
    }
    
    // The startSession() function will only be responsible for starting the camera session.
    private func startSession() async {
        // Checking authorization
        guard await isAuthorized else { return }
        // Start the capture session flow of data
        captureSession.startRunning()
    }
    
    func stopSession() {
        captureSession.stopRunning()
    }
}

// A computed property for the CMSampleBuffer class that allows us to get a CGImage object out of the buffer
extension CMSampleBuffer {
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        guard let imagePixelBuffer = pixelBuffer else { return nil }
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}

// A computed property for the CIImage class, part of the Core Image framework, that allows us to get a CGImage representation of the CIImage object
extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }
        return cgImage
    }
}

// need to be able to receive the various buffer frames from the camera
// implement the captureOutput(_:didOutput:from:) function defined in the AVCaptureVideoDataOutputSampleBufferDelegate protocol
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // called whenever the camera captures a new video frame
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let currentFrame = sampleBuffer.cgImage else { return }
        addToPreviewStream?(currentFrame)
    }
}
