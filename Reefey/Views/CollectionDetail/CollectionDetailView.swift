//
//  CollectionDetailView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with main image
            headerSection

            // Tab selection
            tabSelectionView
            
            // Content based on selected tab
            if selectedTab == 0 {
                collectionGalleryView
            } else {
                infoView
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // This will trigger the back navigation
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
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
    
    private var headerSection: some View {
        ZStack {
            // Main header image
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
            .frame(maxHeight: 300)
        }
    }
    
    private var tabSelectionView: some View {
        VStack {
            Picker("Tab Selection", selection: $selectedTab) {
                Text("Collection").tag(0)
                Text("Info").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onAppear {
                // Change the selected segment background color
                UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color(hex: "#0FAAAC"))
                // Optionally change the overall background
                UISegmentedControl.appearance().backgroundColor = UIColor(Color(hex: "#e0fffb"))
                
                // Change text colors
                UISegmentedControl.appearance().setTitleTextAttributes([
                    .foregroundColor: UIColor.label
                ], for: .normal)
                UISegmentedControl.appearance().setTitleTextAttributes([
                    .foregroundColor: UIColor.white
                ], for: .selected)
            }
            .padding(.horizontal, 20)
        }.padding()
    }
    
    private var collectionGalleryView: some View {
        GeometryReader { geometry in
            let itemSize = (geometry.size.width - 8) / 3 // screen width - total spacing (2px * 4 = 8px)
            
            if collection.photos.isEmpty {
                VStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("No photos available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Photos will appear here once they are added to this collection")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                }
                .background(Color(UIColor.systemBackground))
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.fixed(itemSize), spacing: 2),
                        GridItem(.fixed(itemSize), spacing: 2),
                        GridItem(.fixed(itemSize), spacing: 2)
                    ], spacing: 2) {
                        ForEach(Array(collection.photos.enumerated()), id: \.element.id) { index, photo in
                            CollectionPhotoView(photo: photo)
                                .frame(width: itemSize, height: itemSize)
                                .onTapGesture {
                                    selectedImageIndex = index
                                    showingImageDetail = true
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.top, 2)
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
    
    @ViewBuilder
    private var infoView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
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
            .padding(20)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct CollectionPhotoView: View {
    let photo: CollectionPhoto
    
    var body: some View {
        Group {
            AsyncImage(url: URL(string: photo.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                photoPlaceholder
            }
        }
        .clipped()
        .background(Color.gray.opacity(0.1))
    }
    
    private var photoPlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("Photo")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            )
    }
}

struct InfoSectionView: View {
    let title: String
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
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
            
            if content.count > 1 {
                Divider()
                    .padding(.top, 8)
            }
        }
    }
}

struct ImageDetailView: View {
    let photos: [CollectionPhoto]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    ZStack {
                        AsyncImage(url: URL(string: photo.url)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .tag(index)
                    .onTapGesture {
                        isPresented = false
                    }
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
        }
    }
}

#Preview {
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
