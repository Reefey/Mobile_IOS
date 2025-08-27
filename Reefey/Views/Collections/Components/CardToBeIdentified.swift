//
//  CardToBeIdentified.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//

import SwiftUI
import SwiftData

struct CardToBeIdentified: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var path: [NavigationPath]
    @State private var unidentifiedCount = 0
    
    var body: some View {
        Button(action: {
            path.append(.unidentifiedImages)
        }) {
            HStack {
                Image(systemName: "questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundStyle(Color.primary)
                    .colorInvert()
                VStack(alignment: .leading) {
                    Text("To be identified")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                        .colorInvert()
                    
                    if unidentifiedCount > 0 {
                        Text("\(unidentifiedCount) images")
                            .font(.caption)
                            .foregroundStyle(Color.primary)
                            .colorInvert()
                            .opacity(0.8)
                    } else {
                        Text("No images to identify")
                            .font(.caption)
                            .foregroundStyle(Color.primary)
                            .colorInvert()
                            .opacity(0.8)
                    }
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.primary)
                    .colorInvert()
                    .opacity(0.6)
            }
            .padding()
            .background(Color(hex: "0FAAAC"))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadUnidentifiedCount()
        }
    }
    
    private func loadUnidentifiedCount() {
        let descriptor = FetchDescriptor<UnidentifiedImageModel>()
        do {
            unidentifiedCount = try modelContext.fetch(descriptor).count
        } catch {
            print("Error fetching unidentified count: \(error)")
        }
    }
}

#Preview {
    CardToBeIdentified(path: .constant([]))
}
