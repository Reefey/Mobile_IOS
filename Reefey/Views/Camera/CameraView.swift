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
    @Environment(\.modelContext) private var modelContext
    @Binding var path: [NavigationPath]
    @Binding var cameraShow: Bool
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    @State private var isShowIdentifyDialog = false
    @State private var identifyDialogState: IdentifyDialogEnum = .LOADING
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
                        PhotosPicker(selection: $selectedItem, matching: .images) {
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
                IdentifyDialogView(identifyDialogState: $identifyDialogState)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    // Save to Photos if needed
                    VM.saveToPhotos(image: uiImage) { assetIdentifier in
                        if let identifier = assetIdentifier {
                            print("Photo from picker saved with identifier: \(identifier)")
                        }
                    }
                    
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
    
    private func setupAIFailureCallback() {
        VM.onAIFailure = { [self] assetIdentifier in
            VM.saveToSwiftData(photoAssetIdentifier: assetIdentifier, context: modelContext)
        }
        
        VM.onAIProcessingComplete = { [self] in
            isShowIdentifyDialog = false
        }
        
        VM.onAIUnidentified = { [self] in
            identifyDialogState = .UNIDENTIFIED(
                morePhotosAction: {
                    isShowIdentifyDialog = false
                    identifyDialogState = .LOADING
                },
                viewUnidentifiedAction: {
                    // Handle view unidentified images action
                }
            )
        }
        
        VM.onNetworkUnavailable = { [self] in
            identifyDialogState = .OFFLINE(
                morePhotosAction: {
                    isShowIdentifyDialog = false
                    identifyDialogState = .LOADING
                },
                viewUnidentifiedAction: {
                    // Handle view unidentified images action
                }
            )
        }
    }

}

#Preview {
    CameraView(path: .constant([]), cameraShow: .constant(true))
}
