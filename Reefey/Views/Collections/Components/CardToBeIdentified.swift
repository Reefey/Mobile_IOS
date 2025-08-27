//
//  CardToBeIdentified.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//

import SwiftUI

struct CardToBeIdentified: View {
    @Binding var path: [NavigationPath]
    
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
                    
                    Text("View unidentified images")
                        .font(.caption)
                        .foregroundStyle(Color.primary)
                        .colorInvert()
                        .opacity(0.8)
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
    }
}

#Preview {
    CardToBeIdentified(path: .constant([]))
}
