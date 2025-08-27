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
        Button{
            path = [.toBeIdentified]
        } label : {
            HStack {
                Image(systemName: "questionmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundStyle(Color.primary)
                    .colorInvert()
                VStack {
                    Text("To be identified")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                        .colorInvert()
                        .padding(.bottom, 10)
                }
                Spacer()
            }
            .padding()
            .background(Color(hex: "0FAAAC"))
            .cornerRadius(10)
        }.buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CardToBeIdentified(path: .constant([]))
}
