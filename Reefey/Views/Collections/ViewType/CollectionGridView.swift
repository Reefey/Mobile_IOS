//
//  CollectionGridView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CollectionGridView: View {
    let collections: [Collection]
    @Binding var path: [NavigationPath]
    let onLoadMore: () async -> Void
    let hasMoreData: Bool
    let isLoading: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        if collections.isEmpty {
            // Empty state
            VStack(spacing: 24) {
                Spacer()
                
                // Card to be identified (always show this)
                CardToBeIdentified(path: $path)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "fish.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No collections yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Start by adding your first marine creature to your collection")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                }
            }
        } else {
            VStack(spacing: 10) {
                // Card to be identified
                CardToBeIdentified(path: $path)
                    .padding(.horizontal, 4)
                
                // Collections grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(collections) { collection in
                        CollectionGridItem(collection: collection) {
                            path.append(.collectionDetail(collection))
                        }
                        .onAppear {
                            // Load more data when the last few items appear
                            if collection.id == collections.suffix(4).first?.id && hasMoreData && !isLoading {
                                Task {
                                    await onLoadMore()
                                }
                            }
                        }
                    }
                    
                    // Loading indicator for pagination
                    if isLoading && !collections.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading more...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .gridCellColumns(2) // Span across both columns
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct CollectionGridItem: View {
    let collection: Collection
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Collection Image
                ZStack {
                    if collection.inUserCollection == true && collection.marineImageUrl != nil {
                        // Show user's image if in collection and has imageUrl
                        AsyncImage(url: URL(string: collection.marineImageUrl!)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            placeholderImage
                        }
                    } else {
                        // Show Supabase thumbnail for items not in user collection or without imageUrl
                        placeholderImage
                    }
                }
                .frame(height: 120)
                .clipped()
                
                // Collection Info
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(collection.species)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Scientific Name
                    Text(collection.scientificName ?? "Unknown")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                    
                    // Rarity indicators
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { rarity in
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(rarity <= (collection.rarity ?? 0) ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                        
                        Spacer()
                        
                        Text("\(collection.totalPhotos ?? 0) photos")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 220)
    }
    
    // MARK: - Helper Views
    private var placeholderImage: some View {
        Group {
            if collection.inUserCollection == true {
                // Show Barramundi placeholder for items in user collection
                Image("Barramundi")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Show Supabase thumbnail for items not in user collection
                AsyncImage(url: URL(string: generateThumbnailURL())) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image("Barramundi")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func generateThumbnailURL() -> String {
        let baseURL = "https://puntbmozbsbdzgrjotxt.supabase.co/storage/v1/object/public/reefey-photos/thumbnail/"
        let speciesName = collection.species.lowercased().replacingOccurrences(of: " ", with: "_")
        return "\(baseURL)\(speciesName).svg"
    }
}

#Preview {
    CollectionGridView(
        collections: [],
        path: .constant([]),
        onLoadMore: { },
        hasMoreData: false,
        isLoading: false
    )
}
