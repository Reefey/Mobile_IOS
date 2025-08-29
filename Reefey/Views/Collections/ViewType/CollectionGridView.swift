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
                                         // Use default thumbnail asset for empty state
                     Image(ThumbnailMapper.getDefaultThumbnailAssetName())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
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
                    if collection.inUserCollection == false {
                        // Show thumbnail assets first when no user collection
                        if let scientificName = collection.scientificName,
                           let thumbnailAssetName = ThumbnailMapper.getThumbnailAssetName(for: scientificName) {
                            Image(thumbnailAssetName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            Image(ThumbnailMapper.getDefaultThumbnailAssetName())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else if let imageURL = collection.marineImageUrl {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } placeholder: {
                            Image("Barramundi")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        Image("Barramundi")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(height: 120)
                .clipped()
                .cornerRadius(12)
                
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
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 220)
        .frame(maxWidth: .infinity)
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
