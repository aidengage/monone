//
//  ImageService.swift
//  spots
//
//  Created by Aiden Gage on 6/26/26.
//

import SwiftUI
import UniformTypeIdentifiers

protocol imageServiceProtocol {
    func smartFormat(image: UIImage, path: String) async throws -> String
}

@Observable
class ImageService: imageServiceProtocol {
    private let storageService: storageServiceProtocol
    
    init(storageService: storageServiceProtocol) {
        self.storageService = storageService
    }
    
    func smartFormat(image: UIImage, path: String) async throws -> String {
        let format: ImageFormat
        if let _cgImage = image.cgImage,
            let source = CGImageSourceCreateWithData(UIImage.heicData(image)() as CFData? ?? Data() as CFData, nil),
            let uti = CGImageSourceGetType(source) as? String {
            let type = UTType(uti)
            if type?.conforms(to: .heif) == true || type?.conforms(to: .heic) == true {
                format = .heic
            } else if type?.conforms(to: .png) == true {
                format = .png
            } else {
                format = .jpeg(compressionQuality: 0.7)
            }
        } else {
            format = .jpeg(compressionQuality: 0.7)
        }
        print("smart format is: \(format)")
        
        return try await storageService.uploadFeedbackScreenshot(screenshot: image, path: path, format: format)
    }

}
