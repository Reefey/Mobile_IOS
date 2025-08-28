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
                        
                    } label: {
                        Text("Analyze")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .background(Color(hex: "#0FAAAC"))
                .cornerRadius(20)
                
            }.padding()
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
        isPresented: .constant(true)
    )
}
