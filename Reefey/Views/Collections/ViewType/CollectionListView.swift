//
//  CollectionListView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CollectionListView: View {
    let collections: [Collection]
    @Binding var path: [NavigationPath]
    let onLoadMore: () async -> Void
    let hasMoreData: Bool
    let isLoading: Bool
    
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
            List {
                // Card to be identified
                CardToBeIdentified(path: $path)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                // Collections list
                ForEach(collections) { collection in
                    CollectionListItem(collection: collection) {
                        path.append(.collectionDetail(collection))
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .onAppear {
                        // Load more data when the last few items appear
                        if collection.id == collections.suffix(3).first?.id && hasMoreData && !isLoading {
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
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
            }
            .listStyle(.plain)
        }
    }
}

struct CollectionListItem: View {
    let collection: Collection
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 20) {
                // Collection Image
                ZStack {
                    if let imageURL = collection.marineImageUrl {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image("Barramundi")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    } else {
                        Image("Barramundi")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(width: 120, height: 118)
                .clipped()
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                // Collection Info
                VStack(alignment: .leading) {
                    // Title
                    Text(collection.species)
                        .font(.title3)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Scientific Name
                    Text(collection.scientificName ?? "Unknown")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                    
                    // Rarity indicators
                    HStack {
                        if collection.edibility ?? false {
                            Image("Edible")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        if collection.venomous ?? false{
                            Image("Venomous")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        if collection.poisonous ?? false {
                            Image("Poisonous")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        if collection.endangeredd ?? false{
                            Image("Endanged")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CollectionListView(
        collections: [],
        path: .constant([]),
        onLoadMore: { },
        hasMoreData: false,
        isLoading: false
    )
}
