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
    
    deinit {
        cleanup()
    }
    
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCapturePhotoOutput()
    
    // Session management
    private var isSessionConfigured = false
    private var sessionTask: Task<Void, Never>?
    
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
    
    func cleanup() {
        sessionTask?.cancel()
        sessionTask = nil
        
        // Stop session on background thread to avoid UI blocking
        Task.detached { [session] in
            if session.isRunning {
                session.stopRunning()
            }
        }
        
        stopVolumeHandler()
        
        // Remove all inputs and outputs on background thread
        Task.detached { [session] in
            for input in session.inputs {
                session.removeInput(input)
            }
            for output in session.outputs {
                session.removeOutput(output)
            }
        }
        
        isSessionConfigured = false
    }
    
    func requestAccess() {
        self.requestAccessAndSetup()
        self.askPermissionPhotoLibrary()
    }
    
    func requestAccessAndSetup() {
        sessionTask?.cancel()
        sessionTask = Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted {
                        Task {
                            await self.setup()
                        }
                    } else {
                        logEvent("Camera access denied", OSLog.camera)
                    }
                }
            case .authorized:
                await setup()
            default:
                logEvent("Camera authorization status: Other", OSLog.camera)
            }
        }
    }
    
    private func askPermissionPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Save photo
            }
        }
    }
    
    private func setup() async {
        // Prevent multiple concurrent setup attempts
        guard !isSessionConfigured else { return }
        
        await MainActor.run {
            session.beginConfiguration()
            session.sessionPreset = AVCaptureSession.Preset.photo
        }
        
        do {
            guard let device = AVCaptureDevice.default(for: .video) else {
                logEvent("No video device available", OSLog.camera)
                await MainActor.run { session.commitConfiguration() }
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            await MainActor.run {
                guard session.canAddInput(input) else {
                    logEvent("Cannot add camera input", OSLog.camera)
                    session.commitConfiguration()
                    return
                }
                session.addInput(input)
                
                guard session.canAddOutput(output) else {
                    logEvent("Cannot add photo output", OSLog.camera)
                    session.commitConfiguration()
                    return
                }
                session.addOutput(output)
                
                session.commitConfiguration()
                isSessionConfigured = true
            }
            
            // Start session in background thread (not on MainActor)
            try await withTimeout(seconds: 10) {
                // Run session.startRunning() on background thread
                self.session.startRunning()
                
                // Only update UI elements on MainActor
                await MainActor.run {
                    self.preview.connection?.videoRotationAngle = UIDevice.current.orientation.videoRotationAngle
                }
            }
            
            logEvent("Camera session configured successfully", OSLog.camera)
        } catch {
            logEvent("Camera setup error: \(error.localizedDescription)", OSLog.camera)
            await MainActor.run {
                session.commitConfiguration()
                isSessionConfigured = false
            }
        }
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw CancellationError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
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
        sessionTask?.cancel()
        sessionTask = Task {
            await MainActor.run {
                self.photoCaptureState = .notStarted
            }
            
            if !session.isRunning && isSessionConfigured {
                // Run session.startRunning() on background thread, not MainActor
                session.startRunning()
            }
        }
    }
    
    func setupVolumeHandler(containerView: UIView) {
        guard volumeHandler == nil else { return }
        
        let handler = VolumeButtonHandler(containerView: containerView)
        handler.buttonClosure = { [weak self] button in
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            Task { @MainActor in
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
            Task { @MainActor in
                withAnimation {
                    self.photoCaptureState = .notStarted
                }
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            logEvent("Failed to get image data representation", OSLog.camera)
            Task { @MainActor in
                withAnimation {
                    self.photoCaptureState = .notStarted
                }
            }
            return
        }
        
        guard let provider = CGDataProvider(data: imageData as CFData) else {
            logEvent("Failed to create CGDataProvider", OSLog.camera)
            Task { @MainActor in
                withAnimation {
                    self.photoCaptureState = .notStarted
                }
            }
            return
        }
        
        guard let cgImage = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
            logEvent("Failed to create CGImage", OSLog.camera)
            Task { @MainActor in
                withAnimation {
                    self.photoCaptureState = .notStarted
                }
            }
            return
        }
        
        // Process image in background task with timeout
        sessionTask?.cancel()
        sessionTask = Task {
            do {
                let image = await UIImage(cgImage: cgImage, scale: 1, orientation: UIDevice.current.orientation.uiImageOrientation)
                let imageData = image.jpegData(compressionQuality: 0.9)
                guard let imagePng = imageData else {
                    logEvent("Failed to convert image to JPEG", OSLog.camera)
                    await MainActor.run {
                        withAnimation {
                            self.photoCaptureState = .notStarted
                        }
                    }
                    return
                }
                
                // Add timeout for image resizing
                let resizedImage = try await withTimeout(seconds: 5) {
                    return ImageResize.resize(imageData: imagePng)
                }
                
                // Call template method for subclass-specific handling
                await MainActor.run {
                    self.handlePhotoCapture(image: image, imageData: imagePng, resizedImage: resizedImage, existingAssetIdentifier: nil)
                }
                
                await MainActor.run {
                    withAnimation {
                        self.photoCaptureState = .finished(resizedImage)
                    }
                }
                
                // Reset state after brief delay using structured concurrency
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                await MainActor.run {
                    withAnimation {
                        self.photoCaptureState = .notStarted
                    }
                }
                
            } catch is CancellationError {
                logEvent("Photo processing was cancelled", OSLog.camera)
            } catch {
                logEvent("Photo processing failed: \(error.localizedDescription)", OSLog.camera)
                await MainActor.run {
                    withAnimation {
                        self.photoCaptureState = .notStarted
                    }
                }
            }
        }
    }
}
