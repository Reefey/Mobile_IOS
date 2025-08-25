//
//  CollectionDetailView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header image
            headerImage
                .frame(height: 300)
            
            // Tab selection
            tabSelectionView
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(.ultraThinMaterial)
            
            // Content based on selected tab
            if selectedTab == 0 {
                photosGridView
            } else {
                infoView
            }
            
            Spacer()
        }
        .navigationTitle(collection.species)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    // Navigation will be handled by NavigationStack
                }
                .foregroundColor(.primary)
            }
        }
        .fullScreenCover(isPresented: $showingImageDetail) {
            ImageDetailView(
                photos: collection.photos,
                selectedIndex: $selectedImageIndex,
                isPresented: $showingImageDetail
            )
        }
    }
    
    private var headerImage: some View {
        Group {
            if let imageURL = collection.marineImageUrl, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("tuna")
                        .resizable()
                        .scaledToFill()
                }
            } else {
                Image("tuna")
                    .resizable()
                    .scaledToFill()
            }
        }
        .clipped()
        .ignoresSafeArea(edges: .top)
    }
    
    private var tabSelectionView: some View {
        HStack {
            Spacer()
                .frame(width: 40)
            
            VStack {
                Text("Photos")
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(selectedTab == 0 ? Color(hex: "#0FAAAC") : .clear),
                        alignment: .bottom
                    )
                    .onTapGesture {
                        selectedTab = 0
                    }
            }
            
            Spacer()
            
            VStack {
                Text("Info")
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .overlay(
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(selectedTab == 1 ? Color(hex: "#0FAAAC") : .clear),
                        alignment: .bottom
                    )
                    .onTapGesture {
                        selectedTab = 1
                    }
            }
            
            Spacer()
                .frame(width: 40)
        }
    }
    
    private var photosGridView: some View {
        GeometryReader { geometry in
            let itemSize = (geometry.size.width - 4) / 3
            
            if collection.photos.isEmpty {
                VStack {
                    Spacer()
                    Text("No photos available")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                LazyVGrid(columns: [
                    GridItem(.fixed(itemSize), spacing: 2),
                    GridItem(.fixed(itemSize), spacing: 2),
                    GridItem(.fixed(itemSize), spacing: 2)
                ], spacing: 2) {
                    ForEach(Array(collection.photos.enumerated()), id: \.element.id) { index, photo in
                        AsyncImage(url: URL(string: photo.url)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image("tuna")
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: itemSize, height: itemSize)
                        .clipped()
                        .cornerRadius(0)
                        .onTapGesture {
                            selectedImageIndex = index
                            showingImageDetail = true
                        }
                    }
                }
            }
        }
    }
    
    private var infoView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                InfoSectionView(title: "Basic Information", content: [
                    ("Species", collection.species),
                    ("Scientific Name", collection.scientificName),
                    ("Rarity", "\(collection.rarity)/5"),
                    ("Status", collection.status)
                ])
                
                if let minSize = collection.sizeMinCm, let maxSize = collection.sizeMaxCm {
                    InfoSectionView(title: "Size", content: [
                        ("Size Range", "\(Int(minSize))-\(Int(maxSize)) cm")
                    ])
                }
                
                // var behaviorContent: [(String, String)] = []
                // if let diet = collection.diet { behaviorContent.append(("Diet", diet)) }
                // if let behavior = collection.behavior { behaviorContent.append(("Behavior", behavior)) }
                // if !behaviorContent.isEmpty {
                //     InfoSectionView(title: "Behavior & Diet", content: behaviorContent)
                // }
                
                if !collection.habitatType.isEmpty {
                    InfoSectionView(title: "Habitat", content: [
                        ("Habitat Type", collection.habitatType.joined(separator: ", "))
                    ])
                }
                
                InfoSectionView(title: "Description", content: [
                    ("Details", collection.description)
                ])
                
                InfoSectionView(title: "Sightings", content: [
                    ("Total Photos", "\(collection.totalPhotos)"),
                    ("First Seen", collection.firstSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.firstSeen),
                    ("Last Seen", collection.lastSeenDate?.formatted(date: .abbreviated, time: .omitted) ?? collection.lastSeen)
                ])
            }
            .padding()
        }
    }
}

struct InfoSectionView: View {
    let title: String
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(content, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(item.1)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ImageDetailView: View {
    let photos: [CollectionPhoto]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    if !photos.isEmpty {
                        TabView(selection: $selectedIndex) {
                            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                                AsyncImage(url: URL(string: photo.url)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    } else {
                        Text("No photos available")
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Photo \(selectedIndex + 1) of \(photos.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}



#Preview {
    NavigationView {
        CollectionDetailView(collection: Collection(
            id: 1,
            deviceId: "test-device",
            marineId: 60,
            species: "Bluefin Tuna",
            scientificName: "Thunnus thynnus",
            rarity: 3,
            sizeMinCm: 200.0,
            sizeMaxCm: 400.0,
            habitatType: ["Open Ocean", "Deep Water"],
            diet: "Fish and squid",
            behavior: "Fast swimming predator",
            description: "AI-identified as Bluefin Tuna (Thunnus thynnus)",
            marineImageUrl: nil,
            photos: [
                CollectionPhoto(
                    id: 1,
                    url: "https://example.com/photo1.jpg",
                    annotatedUrl: nil,
                    dateFound: "2025-08-25T07:24:24.45+00:00",
                    spotId: 1,
                    confidence: 0.95,
                    boundingBox: BoundingBox(x: 0.25, y: 0.35, width: 0.45, height: 0.3),
                    spots: nil
                )
            ],
            totalPhotos: 1,
            firstSeen: "2025-08-25T07:24:24.367+00:00",
            lastSeen: "2025-08-25T07:24:24.367+00:00",
            status: "identified"
        ))
    }
}
