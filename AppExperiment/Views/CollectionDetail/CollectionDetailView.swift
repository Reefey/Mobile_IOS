import SwiftUI

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let title: String
    let headerImage: String?
    let items: [CollectionItem]
    let infoSections: [InfoSection]?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0
    @State private var showingImageDetail = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header with main image
                headerSection

                // Tab selection
                tabSelectionView
                
                // Content based on selected tab
                if selectedTab == 0 {
                    collectionGalleryView
                } else {
                    infoView
                }
            }
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingImageDetail) {
            ImageDetailView(
                items: items,
                selectedIndex: $selectedImageIndex,
                isPresented: $showingImageDetail
            )
        }
    }
    
    private var headerSection: some View {
        ZStack {
            // Main header image
            Image("tuna")
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(maxHeight: 300)
        }
    }
    
    private var headerPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Image("tuna")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.6))
            )
    }
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Collection",
                isSelected: selectedTab == 0,
                action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 } }
            )
            
            if infoSections != nil {
                TabButton(
                    title: "Info",
                    isSelected: selectedTab == 1,
                    action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 } }
                )
            }
        }
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
    }
    
    private var collectionGalleryView: some View {
        Group {
            Spacer()
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3),
                    spacing: 2
                ) {
                    ForEach(items.indices, id: \.self) { index in
                        CollectionItemView(item: items[index])
                            .onTapGesture {
                                selectedImageIndex = index
                                showingImageDetail = true
                            }
                    }
                }
                .padding(.horizontal, 2)
                .padding(.top, 2)
            }
            .background(Color(UIColor.systemBackground))
            Spacer()
        }
        
    }
    
    @ViewBuilder
    private var infoView: some View {
        if let infoSections = infoSections {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(infoSections) { section in
                        InfoSectionView(section: section)
                    }
                }
                .padding(20)
            }
            .background(Color(UIColor.systemBackground))
        } else {
            EmptyView()
        }
    }
    
}

// MARK: - Supporting Views
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? Color.teal : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct CollectionItemView: View {
    let item: CollectionItem
    
    var body: some View {
        Group {
            if let imageURL = item.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    itemPlaceholder
                }
            } else {
                itemPlaceholder
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
        .background(Color.gray.opacity(0.1))
    }
    
    private var itemPlaceholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    if !item.title.isEmpty {
                        Text(item.title)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            )
    }
}

struct InfoSectionView: View {
    let section: InfoSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(section.content)
                .font(.system(size: 17))
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            if section != section { // Not the last item
                Divider()
                    .padding(.top, 8)
            }
        }
    }
}

struct ImageDetailView: View {
    let items: [CollectionItem]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            
            TabView(selection: $selectedIndex) {
                ForEach(items.indices, id: \.self) { index in
                    ZStack {
                        if let imageURL = items[index].imageURL {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                        
                                        Text(items[index].title.isEmpty ? "Image \(index + 1)" : items[index].title)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                )
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            // Navigation overlay
            VStack {
                HStack {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .medium))
                    .padding()
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Data Models
struct CollectionItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let imageURL: String?
    let metadata: [String: String]?
    
    init(title: String, imageURL: String? = nil, metadata: [String: String]? = nil) {
        self.title = title
        self.imageURL = imageURL
        self.metadata = metadata
    }
}

struct InfoSection: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

#Preview {
    var sampleTunaItems: [CollectionItem] {
        Array(0...20).map { index in
            CollectionItem(
                title: "Tuna Catch \(index + 1)",
                imageURL: nil, // Add your image URLs here
                metadata: ["weight": "\(Int.random(in: 20...60)) kg"]
            )
        }
    }
    
    var tunaInfoSections: [InfoSection] {
        [
            InfoSection(title: "Species", content: "Bluefin Tuna (Thunnus thynnus)"),
            InfoSection(title: "Weight", content: "45.2 kg"),
            InfoSection(title: "Length", content: "1.2 meters"),
            InfoSection(title: "Location", content: "Pacific Ocean, 200 miles offshore"),
            InfoSection(title: "Date Caught", content: "August 15, 2025"),
            InfoSection(title: "Method", content: "Deep sea trolling"),
            InfoSection(title: "Water Temperature", content: "18°C"),
            InfoSection(title: "Depth", content: "150 meters")
        ]
    }
    CollectionDetailView(
        title: "Tuna",
        headerImage: "nil", // Add your header image URL here
        items: sampleTunaItems,
        infoSections: tunaInfoSections
    )
}
