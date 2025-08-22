//
//  NewCamera.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 20/08/25.
//
import SwiftUI
import PhotosUI

struct CameraView: View {
    @State internal var VM = CameraViewModel()
    @Binding var path: [NavigationPath]
    @Binding var cameraShow: Bool
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
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
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    // Save to Photos if needed
                    VM.saveToPhotos(image: uiImage)
                    
                    // Provide feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    private var cameraPreview: some View {
        CameraPreview(cameraVM: $VM)
            .ignoresSafeArea()
            .onAppear {
                VM.requestAccessAndSetup()
            }
    }

}

#Preview {
    CameraView(path: .constant([]), cameraShow: .constant(true))
}
