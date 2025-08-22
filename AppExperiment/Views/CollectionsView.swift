//
//  CollectionView.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 15/08/25.
//
import SwiftUI

struct CollectionsView : View {
    @Binding var path: [NavigationPath]
    @Binding var cameraShow: Bool
    @State var searchText = ""
    
    var collections: [String] = [
        "All",
        "Fish",
        "Creatures",
        "Corals",
        "Unknown"
    ]
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(collections, id: \.self) { collection in
                            Text(collection)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(hex: "0FAAAC"))
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom)
                }
                Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                    ForEach(0..<5) { row in
                        GridRow {
                            ForEach(0..<2) { column in
                                ZStack {
                                    Image("Barramundi")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.primary.opacity(0.8))
                                    VStack {
                                        HStack{
                                            Text("Tuna Magenta")
                                                .font(.body)
                                                .fontWeight(.bold)
                                            Spacer()
                                        }.padding(10)
                                        Spacer()
                                    }
                                }
                                .background(
                                    .primary.opacity(0.1)
                                )
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                Spacer()
                    .padding(.vertical, 20)
            }
            .padding()
            VStack {
                Spacer()
                HStack {
                    Button {
                        cameraShow = true
                    } label: {
                        Label("New Creature", systemImage: "plus.circle.fill")
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(hex: "#E8F87E"))
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Collections")
        .sheet(isPresented: $cameraShow){
            CameraView(path: $path, cameraShow: $cameraShow)
        }
    }
}

#Preview {
    CollectionsView(path: .constant([]), cameraShow: .constant(false))
}
