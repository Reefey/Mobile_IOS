//
//  BaseCameraViewModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Photos
import os.log

@Observable
class BaseCameraViewModel: NSObject, CameraViewModelProtocol, @unchecked Sendable {
    
    enum PhotoCaptureState {
        case notStarted
        case processing
        case finished(Data)
    }
    
    override init(){
        super.init()
    }
    
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCapturePhotoOutput()
    
    var photoData: Data? {
        if case .finished(let data) = photoCaptureState {
            return data
        }
        return nil
    }
    
    var hasPhoto: Bool { photoData != nil }
    
    private(set) var photoCaptureState: PhotoCaptureState = .notStarted
    
    // Volume Button Handler
    private var volumeHandler: VolumeButtonHandler?
    var onVolumeUpPressed: (() -> Void)?
    var onVolumeDownPressed: (() -> Void)?
    
    func requestAccess() {
        self.requestAccessAndSetup()
        self.askPermissionPhotoLibrary()
    }
    
    func requestAccessAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { disAllowed in
                DispatchQueue.main.async {
                    if disAllowed {
                        self.setup()
                    }
                }
            }
        case .authorized:
            setup()
        default:
            logEvent("Camera authorization status: Other", OSLog.camera)
        }
    }
    
    private func askPermissionPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Save photo
            }
        }
    }
    
    private func setup() {
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        do {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(input) else {return }
            session.addInput(input)
            
            guard session.canAddOutput(output) else {return}
            session.addOutput(output)
            
            session.commitConfiguration()
            
            Task(priority: .background, operation: {
                self.session.startRunning()
                await MainActor.run {
                    self.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
                }
            })
        } catch {
            logEvent("Camera setup error: \(error.localizedDescription)", OSLog.camera)
        }
    }
    
    func takePhoto() {
        guard case .notStarted = photoCaptureState else { return }
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        withAnimation {
            self.photoCaptureState = .processing
        }
    }
    
    func retakePhoto() {
        Task(priority: .background) {
            await MainActor.run {
                self.photoCaptureState = .notStarted
            }
            self.session.startRunning()
        }
    }
    
    func setupVolumeHandler(containerView: UIView) {
        guard volumeHandler == nil else { return }
        
        let handler = VolumeButtonHandler(containerView: containerView)
        handler.buttonClosure = { [weak self] button in
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            DispatchQueue.main.async {
                switch button {
                case .up:
                    self?.onVolumeUpPressed?()
                case .down:
                    self?.onVolumeDownPressed?()
                }
            }
        }
        handler.start()
        self.volumeHandler = handler
    }
    
    func stopVolumeHandler() {
        volumeHandler?.stop()
        volumeHandler = nil
    }
    
    // Template methods to be overridden by subclasses
    func handlePhotoCapture(image: UIImage, imageData: Data, resizedImage: Data, existingAssetIdentifier: String? = nil) {
        // Override in subclasses
    }
}

extension BaseCameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error {
            logEvent("Photo capture error: \(error.localizedDescription)", OSLog.camera)
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        guard let provider = CGDataProvider(data: imageData as CFData) else { return }
        guard let cgImage = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return }
        
        Task(priority: .background) {
            let image = await UIImage(cgImage: cgImage, scale: 1, orientation: UIDevice.current.orientation.uiImageOrientation)
            let imageData = image.jpegData(compressionQuality: 0.9)
            guard let imagePng = imageData else { return }
            let resizedImage = ImageResize.resize(imageData: imagePng)
            
            // Call template method for subclass-specific handling
            await MainActor.run {
                self.handlePhotoCapture(image: image, imageData: imagePng, resizedImage: resizedImage, existingAssetIdentifier: nil)
            }
            
            await MainActor.run {
                withAnimation {
                    self.photoCaptureState = .finished(resizedImage)
                }
                
                // Reset state after brief delay to allow animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.photoCaptureState = .notStarted
                }
            }
        }
    }
}