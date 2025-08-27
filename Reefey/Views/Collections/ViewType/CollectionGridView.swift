//
//  CollectionGridView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CollectionGridView: View {
    let collections: [MarineSpecies]
    @Binding var path: [NavigationPath]
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        if collections.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.6))
                
                Text("No collections yet")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                
                Text("Your marine species collections will appear here")
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 60)
        } else {
            VStack(spacing: 10) {
                // Card to be identified
                CardToBeIdentified()
                    .padding(.horizontal, 4)
                
                // Collections grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(collections) { collection in
                        CollectionGridItem(collection: collection) {
                            path.append(.collectionDetail(collection))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct CollectionGridItem: View {
    let collection: MarineSpecies
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Collection Image
                ZStack {
                    if let imageURL = collection.imageUrl {
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
                .frame(height: 120)
                .clipped()
                
                // Collection Info
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(collection.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Scientific Name
                    Text(collection.scientificName)
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
                                .foregroundStyle(rarity <= collection.rarity ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                        
                        Spacer()
                        
                        Text("\(collection.totalPhotos) photos")
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
    }
}

#Preview {
    CollectionGridView(
        collections: [],
        path: .constant([])
    )
}
