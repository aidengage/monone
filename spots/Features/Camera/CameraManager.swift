// https://www.youtube.com/watch?v=ik1QRc_kN9M

import SwiftUI
import AVFoundation
import Combine

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        if let error = error {
            print("video recording error \(error.localizedDescription)")
            return
        }
        
        DispatchQueue.main.async {
            [weak self] in
            self?.recordedVideoURL = outputFileURL
        }
    }
    
    @Published var capturedImage: IdentifiableImage?
    @Published var isSessionRunning = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var isRecording = false
    @Published var recordedVideoURL: URL?
    private var outputURL: URL?
    
    let session = AVCaptureSession()
    
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var currentInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.monone.camera.sessionQueue")
    
    override init() {
        super.init()
    }
    
    func checkAuth() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            authorizationStatus = .authorized
            setupSession()
        case .notDetermined:
            authorizationStatus = .notDetermined
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationStatus = granted ? .authorized : .denied
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        case .denied:
            authorizationStatus = .denied
        @unknown default:
            authorizationStatus = .denied
        
        }
    }
    
    private func setupSession() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            //quality
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            
            //cam input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: camera) else {
                print("failed to access camera")
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.currentInput = input
            }
            
            // add output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                
                self.photoOutput.isHighResolutionCaptureEnabled = true
//                self.photoOutput.maxPhotoDimensions = .init(width: 1920, height: 1080)
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            // added video output
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
            
            //mic output
            if let mic = AVCaptureDevice.default(for: .audio),
                let audioInput = try? AVCaptureDeviceInput(device: mic),
                self.session.canAddInput(audioInput) {
                self.session.addInput(audioInput)
            }
            
            self.session.commitConfiguration()
            
            //start
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    func capturePhoto() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            
            if self.photoOutput.isHighResolutionCaptureEnabled {
                settings.isHighResolutionPhotoEnabled = true
            }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("photo capture error: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(), let uiImage = UIImage(data: imageData) else {
            print("failed to convert photo to image")
            return
        }
        
        DispatchQueue.main.async {
            [weak self] in
            self?.capturedImage = IdentifiableImage(image: uiImage)
        }
    }
    
    func startRecording() {
        sessionQueue.async {
            [weak self] in
            guard let self else { return }
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(AVFileType.mov.rawValue)
            
            self.outputURL = tempURL
            
            // start recording to file
            self.videoOutput.startRecording(to: tempURL, recordingDelegate: self)
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
    
    func stopRecording() {
        sessionQueue.async {
            [weak self] in
            self?.videoOutput.stopRecording()
            
            DispatchQueue.main.async {
                self?.isRecording = false
            }
        }
    }
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
