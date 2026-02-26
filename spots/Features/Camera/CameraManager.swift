// https://www.youtube.com/watch?v=ik1QRc_kN9M

import SwiftUI
import Photos
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
            self?.recordedVideoURL = IdentifiableURL(url: outputFileURL)
        }
    }
    
    @Published var capturedImage: IdentifiableImage?
    @Published var capturedImages: [IdentifiableImage?] = []
    @Published var showPhotoPreview: Bool = false
    // vide preview bool
    @Published var isSessionRunning = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var isRecording = false
    @Published var recordedVideoURL: IdentifiableURL?
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var zoomFactor: CGFloat = 1.0
    @Published var latestThumbnail: UIImage? = nil
    private let minZoom: CGFloat = 1.0
    private let maxZoom: CGFloat = 5.0
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
            
            // add camera output
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
            settings.flashMode = self.flashMode
            
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
//            self?.latestThumbnail = self?.capturedImage?.image // need rework
        }
    }
    
    func updateLibraryThumbnail(image: UIImage?) {
        if image == nil {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("permission denied")
                    return
                }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                DispatchQueue.main.async {
                    if let lastAsset = fetchResult.firstObject {
                        PHImageManager.default().requestImage(for: lastAsset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) { uiImage, _ in
                            if let uiImage = uiImage {
                                self.latestThumbnail = uiImage
                            }}
                    }
                }
            }
        } else {
            let targetSize = CGSize(width: 200, height: 200)
            self.latestThumbnail = image
//            self.latestThumbnail = image?.resizeImageTo(size: targetSize) // need consistent resolution like above
        }
    }
    
    func startRecording() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            
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
    
    func switchCamera() {
        sessionQueue.async {
            [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            //remove current input
            if let currentInput = self.currentInput {
                self.session.removeInput(currentInput)
            }
            
            let currentPosition = self.currentInput?.device.position ?? .back
            let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
            
            guard let newCam = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: newCam) else {
                // fail new cam
                if let currentInput = self.currentInput,
                   self.session.canAddInput(currentInput) {
                    self.session.addInput(currentInput)
                }
                self.session.commitConfiguration()
                return
            }
            
            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.currentInput = newInput
            }
            self.session.commitConfiguration()
        }
    }
    
    func toggleFlash() {
        flashMode = switch flashMode {
        case .off:
            .on
        case .on:
            .auto
        case .auto:
            .off
        @unknown default:
            .off
        }
    }
    
    func zoom(factor: CGFloat) {
        sessionQueue.async {
            [weak self] in
            guard let self, let device = self.currentInput?.device else { return }
            
            do {
                try device.lockForConfiguration()
                
                //clamp zoom
                let clampView = max(self.minZoom, min(factor, min(self.maxZoom, device.activeFormat.videoMaxZoomFactor)))
                
                device.videoZoomFactor = clampView
                
                DispatchQueue.main.async {
                    self.zoomFactor = clampView
                }
                device.unlockForConfiguration()
            } catch {
                print("zoom error: \(error.localizedDescription)")
            }
        }
    }
}
