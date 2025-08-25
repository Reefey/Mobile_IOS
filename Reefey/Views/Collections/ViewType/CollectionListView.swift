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
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Card to be identified
                CardToBeIdentified()
                    .padding(.horizontal, 16)
                
                // Collections list
                ForEach(collections) { collection in
                    CollectionListItem(collection: collection) {
                        path.append(.collectionDetail(collection))
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct CollectionListItem: View {
    let collection: Collection
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
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
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                // Collection Info
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(collection.species)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Scientific Name
                    Text(collection.scientificName)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                    
                    // Rarity indicators
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { rarity in
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(rarity <= collection.rarity ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 16, height: 16)
                        }
                        
                        Spacer()
                        
                        Text("\(collection.totalPhotos) photos")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Status indicator
                Text(collection.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(collection.status == "identified" ? Color.green : Color.orange)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CollectionListView(
        collections: [],
        path: .constant([])
    )
}
