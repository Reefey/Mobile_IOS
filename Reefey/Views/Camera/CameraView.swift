//
//  NewCamera.swift
//  Reefey
//
//  Created by Reza Juliandri on 20/08/25.
//
import SwiftUI
import PhotosUI
import SwiftData

struct CameraView: View {
    @State internal var VM = CameraViewModel()
    @Environment(\.modelContext) var modelContext
    @Binding var path: [NavigationPath]
    @Binding var cameraShow: Bool
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    @State var isShowIdentifyDialog = false
    @State var identifyDialogState: IdentifyDialogEnum = .LOADING
    var body: some View {
        ZStack {
            cameraPreview
            VStack {
                Spacer()
                Image(systemName: "viewfinder")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.ultraThinMaterial)
                    .fontWeight(.thin)
                    .frame(width: 300, height: 300)
                Spacer()
                VStack {
                    HStack {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Circle()
                                .fill(Color.black.opacity(0.2))
                                .overlay {
                                    Image(systemName: "photo.on.rectangle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .padding(12)
                                }
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        Button {
                            isShowIdentifyDialog = true
                            identifyDialogState = .LOADING
                            VM.takePhoto()
                        } label : {
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 65)
                                Circle()
                                    .stroke(.white)
                                    .frame(width: 75)
                            }
                        }
                        
                        Spacer()
                        Button {
                            // Lock button
                            path = [.lockedCamera]
                            cameraShow = false
                        } label: {
                            Circle()
                                .fill(Color.black.opacity(0.2)) // background opsional
                                .overlay {
                                    Image(systemName: "lock.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .padding(12)
                                }
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal,20)
                    .padding(.bottom, 40)
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
            if isShowIdentifyDialog {
                IdentifyDialogView(identifyDialogState: $identifyDialogState, isShowIdentifyDialog: $isShowIdentifyDialog)
            }
        }
        .onAppear {
            // Check if we should show UNLOCK dialog from CameraLockView
            if UserDefaults.standard.bool(forKey: "shouldShowUnlockDialog") {
                isShowIdentifyDialog = true
                identifyDialogState = .UNLOCK(
                    viewUnidentifiedAction: {
                        isShowIdentifyDialog = false
                        // Handle view unidentified images action
                    },
                    dismissAction: {
                        isShowIdentifyDialog = false
                    }
                )
                UserDefaults.standard.removeObject(forKey: "shouldShowUnlockDialog")
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let newItem,
                   let assetIdentifier = newItem.itemIdentifier,
                   let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    
                    // Show identify dialog for gallery image processing
                    isShowIdentifyDialog = true
                    identifyDialogState = .LOADING
                    
                    // Process gallery image with same flow as camera
                    let imageData = uiImage.jpegData(compressionQuality: 0.9) ?? data
                    let resizedImage = ImageResize.resize(imageData: imageData)
                    
                    // Use the same processing flow as camera capture, but with existing asset identifier
                    VM.handlePhotoCapture(image: uiImage, imageData: imageData, resizedImage: resizedImage, existingAssetIdentifier: assetIdentifier)
                    
                    // Provide feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    private var cameraPreview: some View {
        CameraPreview<CameraViewModel>(cameraVM: $VM)
            .ignoresSafeArea()
            .onAppear {
                VM.requestAccessAndSetup()
                setupAIFailureCallback()
            }
    }

}

#Preview {
    CameraView(path: .constant([]), cameraShow: .constant(true))
}
