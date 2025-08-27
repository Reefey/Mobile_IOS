//
//  DataDialogView.swift
//  Reefey
//
//  Created by Reza Juliandri on 27/08/25.
//
import SwiftUI

struct DataDialogView: View {
    var marineData: MarineData
    var capturedImage: UIImage?
    @Binding var isShowIdentifyDialog: Bool
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                // Image section - use captured image if available, otherwise fallback to remote URL
                Group {
                    if let capturedImage = capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        AsyncImage(url: URL(string: marineData.imageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image("tuna")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                }
                .frame(height: 200)
                .clipped()
                
                // Content section with teal background extending to edges
                VStack(spacing: 16) {
                    Text(marineData.name)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    // Icon row
                    HStack(spacing: 16) {
                        // Edible icon (fork and knife)
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            Image(systemName: "fork.knife")
                                .foregroundColor(Color(hex: "#4CAFA1"))
                                .font(.system(size: 18))
                        }
                        
                        // Warning icon (hand with lines)
                        ZStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 40, height: 40)
                            Image(systemName: "hand.raised")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        
                        // Toxic/danger icon (skull)
                        ZStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 40, height: 40)
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        
                        // Not allowed icon (prohibition sign)
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 40, height: 40)
                            Image(systemName: "nosign")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                    }
                    
                    // View details button
                    Button(action: {
                        // Add your action here
                    }) {
                        HStack {
                            Spacer()
                            Text("View details")
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#4CAFA1"))
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(20)
                .frame(maxWidth: .infinity) // This ensures the background extends to full width
                .background(Color(hex: "#4CAFA1"))
            }
            .background(Color(hex: "#4CAFA1")) // Additional background to ensure full coverage
            .cornerRadius(16)
            .overlay(
                // X button overlay
                Button {
                    isShowIdentifyDialog = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: -12, y: 12),
                alignment: .topTrailing
            )
            .frame(maxWidth: 280)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    DataDialogView(
        marineData: MarineData(
        id: 1,
        name: "Clownfish",
        scientificName: "Amphiprioninae",
        category: "Fish",
        rarity: 3,
        sizeMinCm: 7,
        sizeMaxCm: 16,
        habitatType: ["Coral Reef", "Tropical Waters"],
        diet: "Omnivore",
        behavior: "Territorial",
        danger: "Low",
        venomous: false,
        description: "A small, colorful fish known for living symbiotically with sea anemones.",
        lifeSpan: "6-10 years",
        reproduction: "Sequential hermaphrodites",
        migration: "None",
        endangered: "Least Concern",
        funFact: "All clownfish are born male and can change to female when needed!",
        imageUrl: "https://example.com/clownfish.jpg",
        createdAt: "2025-08-26",
        updatedAt: "2025-08-26"
        ),
        capturedImage: nil,
        isShowIdentifyDialog: .constant(true)
    )
}
