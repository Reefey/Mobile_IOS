//
//  UnidentifiedImageDetailView.swift
//  Reefey
//
//  Created by Reza Juliandri on 28/08/25.
//


import SwiftUI
import SwiftData
import Photos

struct UnidentifiedImageDetailView: View {
    let images: [UnidentifiedImageModel]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    @Binding var path: [NavigationPath]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = UnidentifiedImageDetailViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageModel in
                    UnidentifiedImageFullView(imageModel: imageModel)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            // Navigation overlay
            VStack {
                HStack {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .medium))
                    .padding()
                    
                    Spacer()
                }
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await viewModel.analyzeImage(images[selectedIndex], modelContext: modelContext) { marineId in
                                // Close the current view first
                                isPresented = false
                                // Navigate to detail after a small delay to ensure sheet is dismissed
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    path = [.marineDetail(marineId)]
                                }
                            }
                        }
                    } label: {
                        if viewModel.isAnalyzing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Identify")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.isAnalyzing)
                    Spacer()
                }
                .background(Color(hex: "#0FAAAC"))
                .cornerRadius(20)
                
            }.padding()
        }
        .alert("Analysis Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    UnidentifiedImageDetailView(
        images: [
            UnidentifiedImageModel(
                photoAssetIdentifier: "",
                dateTaken: Date(),
                isProcessed: false
            )
        ],
        selectedIndex: .constant(0),
        isPresented: .constant(true),
        path: .constant([])
    )
}
