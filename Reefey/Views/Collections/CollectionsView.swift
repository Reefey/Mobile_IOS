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
    @State private var viewModel = CollectionsViewModel()
    @State private var selectedView: CollectionViewTypeEnum = .LIST
    
    var body: some View {
        ZStack {
            VStack {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // All category
                        CategoryChip(
                            category: CollectionCategoryEnum.ALL,
                            isSelected: viewModel.selectedCategory == "ALL"
                        ) {
                            Task {
                                await viewModel.selectCategory("ALL")
                            }
                        }
                        
                        // Available categories
                        ForEach(viewModel.availableCategories, id: \.self) { category in
                            if category != "ALL" {
                                CategoryChip(
                                    category: CollectionCategoryEnum(rawValue: category) ?? .UNKNOWN,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    Task {
                                        await viewModel.selectCategory(category)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
                
                // Content
                switch selectedView {
                case .GRID:
                    ScrollView(showsIndicators: false) {
                        CollectionGridView(collections: viewModel.collections, path: $path)
                    }
                    .padding(.horizontal)
                case .LIST:
                    CollectionListView(collections: viewModel.collections, path: $path)
                }
            }
            
            // Loading overlay
            if viewModel.isLoading {
                ProgressView("Loading collections...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            
            // Error overlay
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await viewModel.loadCollections(refresh: true)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) { _, _ in
            Task {
                await viewModel.searchCollections()
            }
        }
        .navigationTitle("Collections")
        .sheet(isPresented: $cameraShow){
            CameraView(path: $path, cameraShow: $cameraShow)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // View toggle button
                Button {
                    selectedView = selectedView == .GRID ? .LIST : .GRID
                } label: {
                    Image(systemName: selectedView == .GRID ? "list.bullet" : "rectangle.grid.2x2")
                }
                
                // Filter button
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
