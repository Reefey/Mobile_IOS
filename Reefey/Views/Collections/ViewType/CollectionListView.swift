//
//  CollectionListView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CollectionListView: View {
    @State
    var isFavorite: Bool = true
    var body: some View {
        List {
            CardToBeIdentified()
            ForEach(0..<10, id: \.self) { _ in
                HStack(alignment: .top, spacing: 20) {
                    Image("Barramundi")
                        .resizable()
                        .frame(width: 120, height: 118)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .cornerRadius(20)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Barramudi")
                            .font(.title2)
                        
                        Text("Fish")
                            .font(.body)
                        
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(hex: "#CE5656"))
                                .frame(width: 40, height: 40)
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(hex: "#D89F65"))
                                .frame(width: 40, height: 40)
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(hex: "#61C361"))
                                .frame(width: 40, height: 40)
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(hex: "#9948C2"))
                                .frame(width: 40, height: 40)
                        }
                    }
                    
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
    }
}


#Preview {
    //    CollectionListView()
    CollectionsView(path: .constant([]), cameraShow: .constant(false))
}
