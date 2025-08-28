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
//                Image(systemName: "questionmark")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 20)
//                    .foregroundStyle(Color(hex: "#145B55"))
                VStack {
                    Text("To be identified")
                        .font(.custom("EBGaramond-Regular", size: 24, relativeTo: .body))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "#145B55"))
                        .padding(.bottom, 35)
                }
                Spacer()
                
            }
            .padding()
            .background(
                ZStack {
                    Image("BannerButton")
                        .resizable()
                        .scaledToFill()
                    Color.white.opacity(0.1)
                }
                
            )
            .cornerRadius(10)
        }.buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CardToBeIdentified(path: .constant([]))
}
