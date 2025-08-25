//
//  CameraViewModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 15/08/25.
//


//
//  CameraViewModel.swift
//  Camera
//
//  Created by Reza Juliandri on 17/04/25.
//
import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Photos

@Observable
final class CameraViewModel: NSObject {
    
    enum PhotoCaptureState {
        case notStarted
        case processing
        case finished(Data)
    }
    
    override init(){
        super.init()
        // Don't request permissions in init - defer to when actually needed
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
            print("Other Status")
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
            print(error.localizedDescription)
        }
    }
    
    func takePhoto() {
        guard case .notStarted = photoCaptureState else { return }
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        withAnimation {
            self.photoCaptureState = .processing
        }
    }
    func saveToPhotos(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: image)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Photo saved successfully")
                } else if let error = error {
                    print("Error saving photo: \(error)")
                }
            }
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
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate, Sendable {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let error {
            print(error.localizedDescription)
        }
        
        guard let imageData = photo.fileDataRepresentation( ) else { return }
        
        guard let provider = CGDataProvider(data: imageData as CFData) else { return }
        guard let cgImage = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return }
        
        Task(priority: .background) {
            await MainActor.run {
                let image = UIImage(cgImage: cgImage, scale: 1, orientation: UIDevice.current.orientation.uiImageOrientation)
                let imageData = image.pngData()
                
                // Auto-save to Photos
                self.saveToPhotos(image: image)
                
                withAnimation {
                    if let imageData {
                        self.photoCaptureState = .finished(imageData)
                    } else {
                        print("error occured while capturing photo")
                    }
                }
                
                // Reset state after brief delay to allow animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.photoCaptureState = .notStarted
                }
            }
        }
    }
}
