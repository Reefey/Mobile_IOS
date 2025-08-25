//
//  CollectionView.swift
//  Reefey
//
//  Created by Reza Juliandri on 15/08/25.
//
import SwiftUI

struct CollectionsView : View {
    @Binding var path: [NavigationPath]
    @Binding var cameraShow: Bool
    @State var searchText = ""
    
    var categories: [CollectionCategoryEnum] = CollectionCategoryEnum.allCases
    
    @State
    var selectedCategory: CollectionCategoryEnum = .ALL
    @State
    var selectedView: CollectionViewTypeEnum = .LIST
    var body: some View {
        ZStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(category: category, isSelected: category == selectedCategory) {
                                selectedCategory = category
                            }
                            
                        }
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
                
                switch selectedView {
                case .GRID:
                    ScrollView(showsIndicators: false) {
                        CollectionGridView()
                    }
                    .padding(.horizontal)
                case .LIST:
                    CollectionListView()
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Collections")
        .sheet(isPresented: $cameraShow){
            CameraView(path: $path, cameraShow: $cameraShow)
        }
        .toolbar {
            // Simple button on the trailing side
            switch selectedView {
            case .GRID:
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedView = .LIST
                    } label: {
                        Image(systemName: "rectangle.grid.2x2")
                    }
                }
            case .LIST:
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedView = .GRID
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("Filter tapped")
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            
            // Bottom bar item
            ToolbarItem(placement: .bottomBar) {
                Button {
                    cameraShow = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.primary)
                            .colorInvert()
                        Text("New Creature").fontWeight(.bold)
                            .foregroundStyle(Color.primary)
                            .colorInvert()
                    }
                    .padding(.horizontal, 12)
                    .fixedSize(horizontal: true, vertical: false)
                    .contentShape(Rectangle())
                }
            }
        }
        .toolbarBackground(Color(hex:"#0FAAAC"), for: .bottomBar)
        .toolbarBackground(.visible, for: .bottomBar)
    }
}

#Preview {
    CollectionsView(path: .constant([]), cameraShow: .constant(false))
}
