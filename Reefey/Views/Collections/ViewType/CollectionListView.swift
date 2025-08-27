//
//  CollectionListView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CollectionListView: View {
    let collections: [MarineSpecies]
    @Binding var path: [NavigationPath]
    
    var body: some View {
        if collections.isEmpty {
            // Empty state
            VStack(spacing: 24) {
                Spacer()
                
                // Card to be identified (always show this)
                CardToBeIdentified(path: $path)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
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
                }
            }
            .listStyle(.plain)
        }
    }
}

struct CollectionListItem: View {
    let collection: MarineSpecies
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 20) {
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
                    Text(collection.name)
                        .font(.title2)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Scientific Name
                    Text(collection.scientificName)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(1)
                    
                    // Rarity indicators
                    HStack {
                        ForEach(1...5, id: \.self) { rarity in
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(rarity <= collection.rarity ? getRarityColor(rarity) : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getRarityColor(_ rarity: Int) -> Color {
        switch rarity {
        case 1: return Color(hex: "#CE5656") // Red
        case 2: return Color(hex: "#D89F65") // Orange
        case 3: return Color(hex: "#61C361") // Green
        case 4: return Color(hex: "#9948C2") // Purple
        case 5: return Color(hex: "#0FAAAC") // Teal
        default: return Color.gray
        }
    }
}

#Preview {
    CollectionListView(
        collections: [],
        path: .constant([])
    )
}
