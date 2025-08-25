//
//  CollectionDetailView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//

import SwiftUI

struct CollectionDetailViewBak: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("tuna")
                .resizable()
                .scaledToFill()
                .clipped()
                .ignoresSafeArea(edges: .top)
                .frame(height: 300)
            HStack {
                Spacer()
                    .frame(width: 40)
                VStack {
                    Text("Caught")
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                        .overlay(
                            Rectangle()
                                .frame(height: 3)
                                .foregroundColor(Color(hex: "#0FAAAC")),
                            alignment: .bottom
                        )
                }
                Spacer()
                VStack {
                    Text("Info")
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                        .overlay(
                            Rectangle()
                                .frame(height: 3)
                                .foregroundColor(.clear),
                            alignment: .bottom
                        )
                }
                Spacer()
                    .frame(width: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(.ultraThinMaterial)
            
            GeometryReader { geometry in
                let itemSize = (geometry.size.width - 4) / 3 // screen width - total spacing only
                
                LazyVGrid(columns: [
                    GridItem(.fixed(itemSize), spacing: 2),
                    GridItem(.fixed(itemSize), spacing: 2),
                    GridItem(.fixed(itemSize), spacing: 2)
                ], spacing: 2) {
                    ForEach(0..<10, id: \.self) { index in
                        Image("tuna")
                            .resizable()
                            .scaledToFill()
                            .frame(width: itemSize, height: itemSize)
                            .clipped()
                            .cornerRadius(0)
                            .onTapGesture {
                                // Handle tap
                                print("Tapped image \(index)")
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    CollectionDetailViewBak()
}
