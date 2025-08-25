//
//  CollectionGridView.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//
import SwiftUI

struct CollectionGridView: View {
    var body: some View {
        Group {
            CardToBeIdentified()
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(0..<5) { row in
                    GridRow {
                        ForEach(0..<2) { column in
                            ZStack {
                                Image("Barramundi")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundStyle(.primary.opacity(0.8))
                                VStack {
                                    HStack{
                                        Text("Barramundi")
                                            .font(.body)
                                            .fontWeight(.bold)
                                        Spacer()
                                    }.padding(10)
                                    Spacer()
                                }
                                VStack {
                                    Spacer()
                                    HStack {
                                        HStack(spacing: 3) {
                                            Image(systemName: "questionmark.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color(hex: "#CE5656"))
                                                .frame(width: 15, height: 15)
                                            Image(systemName: "questionmark.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color(hex: "#D89F65"))
                                                .frame(width: 15, height: 15)
                                            Image(systemName: "questionmark.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color(hex: "#61C361"))
                                                .frame(width: 15, height: 15)
                                            Image(systemName: "questionmark.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundStyle(Color(hex: "#9948C2"))
                                                .frame(width: 15, height: 15)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .background(.ultraThinMaterial.opacity(0.5))
                                        .cornerRadius(20)
                                        Spacer()
                                    }
                                    
                                }
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    CollectionGridView()
}
