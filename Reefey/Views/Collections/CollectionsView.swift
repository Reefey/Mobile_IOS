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
    @State private var showDebugView = false
    
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
                if viewModel.isLoading && viewModel.collections.isEmpty {
                    loadingView
                } else if viewModel.collections.isEmpty {
                    emptyStateView
                } else {
                    switch selectedView {
                    case .GRID:
                        ScrollView(showsIndicators: false) {
                            CollectionGridView(
                                collections: viewModel.collections,
                                path: $path,
                                onLoadMore: {
                                    await viewModel.loadMoreCollections()
                                },
                                hasMoreData: viewModel.hasMoreData,
                                isLoading: viewModel.isLoading
                            )
                        }
                        .padding(.horizontal)
                    case .LIST:
                        CollectionListView(
                            collections: viewModel.collections,
                            path: $path,
                            onLoadMore: {
                                await viewModel.loadMoreCollections()
                            },
                            hasMoreData: viewModel.hasMoreData,
                            isLoading: viewModel.isLoading
                        )
                    }
                }
            }
            
            // Loading overlay for pagination (when there are existing collections)
            if viewModel.isLoading && !viewModel.collections.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                }
                .padding(.bottom, 100) // Account for bottom toolbar
            }
            
            // Error overlay
            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 8) {
                        Text("Oops! Something went wrong")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    Button("Try Again") {
                        Task {
                            await viewModel.loadCollections(refresh: true)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(32)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 10)
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
        .fullScreenCover(isPresented: $showDebugView) {
            UnidentifiedImagesDebugView()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Debug button
                Button {
                    showDebugView = true
                } label: {
                    Image(systemName: "ladybug")
                        .foregroundColor(.orange)
                }
                
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
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color(hex: "#0FAAAC"))
                
                Text("Loading Collections")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Text("Please wait while we fetch your marine discoveries...")
                //     .font(.body)
                //     .foregroundColor(.secondary)
                //     .multilineTextAlignment(.center)
                //     .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                // Use a random thumbnail asset for empty state
                Image(ThumbnailMapper.getRandomThumbnailAssetName())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray.opacity(0.6))
                
                Text("No Collections Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Start your marine adventure by capturing your first creature!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Button("Capture New Creature") {
            //     cameraShow = true
            // }
            // .buttonStyle(.borderedProminent)
            // .controlSize(.large)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    CollectionsView(path: .constant([]), cameraShow: .constant(false))
}
