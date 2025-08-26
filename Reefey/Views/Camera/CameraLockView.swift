//
//  CameraLockView.swift
//  Reefey
//
//  Created by Reza Juliandri on 22/08/25.
//
import SwiftUI
import UIKit
import SwiftData

struct CameraLockView: View {
    @State internal var VM = CameraLockViewModel()
    @Environment(\.modelContext) private var modelContext
    @Binding var path: [NavigationPath]
    @Binding var cameraShow: Bool
    @State private var isPressed = false
    @State private var pressTimer: Timer?
    @State private var hapticTimer: Timer?
    @State private var picturesTaken = 0
    
    // Container for volume handler
    @State private var containerView = UIView()
    
    var body: some View {
        ZStack {
            cameraPreview
            VStack {
                Spacer()
                VStack {
                    HStack {
                        
                        Spacer()
                        Button {
                            // Action happens in gesture handlers
                        } label: {
                            Circle()
                                .fill(Color.black.opacity(0.2)) // background opsional
                                .overlay {
                                    Image(systemName: "lock.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .padding(12)
                                }
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                                .scaleEffect(isPressed ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: isPressed)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !isPressed {
                                        startPressSequence()
                                    }
                                }
                                .onEnded { _ in
                                    cancelPressSequence()
                                }
                        )
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom, 40)
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .statusBarHidden()
        .ignoresSafeArea(.all)
        .background(
            UIViewWrapper(view: containerView)
        )
        .onAppear {
            setupVolumeCallbacks()
            setupSwiftDataCallback()
            VM.setupVolumeHandler(containerView: containerView)
        }
        .onDisappear {
            VM.stopVolumeHandler()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            VM.setupVolumeHandler(containerView: containerView)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            VM.stopVolumeHandler()
        }
    }
    private var cameraPreview: some View {
        CameraPreview<CameraLockViewModel>(cameraVM: $VM)
            .ignoresSafeArea()
            .onAppear {
                VM.requestAccessAndSetup()
            }
    }
    
    private func startPressSequence() {
        isPressed = true
        
        // Start haptic feedback every 0.5 seconds
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        
        // Set timer for 5 seconds to unlock
        pressTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            unlockCamera()
        }
    }
    
    private func cancelPressSequence() {
        isPressed = false
        pressTimer?.invalidate()
        hapticTimer?.invalidate()
        pressTimer = nil
        hapticTimer = nil
    }
    
    private func unlockCamera() {
        cancelPressSequence()
        
        // Final success haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Unlock action - only show if pictures were taken
        if picturesTaken > 0 {
            // Pass info to show UNLOCK dialog
            UserDefaults.standard.set(true, forKey: "shouldShowUnlockDialog")
        }
        
        cameraShow = true
        path = []
    }
    
    private func setupVolumeCallbacks() {
        VM.onVolumeUpPressed = {
            handleVolumeUpPress()
        }
        VM.onVolumeDownPressed = {
            handleVolumeDownPress()
        }
    }
    
    private func setupSwiftDataCallback() {
        VM.onPhotoCapture = { [self] assetIdentifier in
            VM.saveToSwiftData(photoAssetIdentifier: assetIdentifier, context: modelContext)
        }
    }
    
    private func handleVolumeUpPress() {
        print("Volume Up pressed")
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func handleVolumeDownPress() {
        print("Volume Down pressed")
        VM.takePhoto()
        picturesTaken += 1
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

}

struct UIViewWrapper: UIViewRepresentable {
    let view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraLockView(path: .constant([]), cameraShow: .constant(true))
}
