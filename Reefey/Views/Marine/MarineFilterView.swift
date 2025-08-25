import SwiftUI

struct MarineFilterView: View {
    @Bindable var viewModel: MarineViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Category Section
                Section("Category") {
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        HStack {
                            Text(category)
                            Spacer()
                            if viewModel.selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                
                // Rarity Section
                Section("Rarity") {
                    HStack {
                        Text("Any Rarity")
                        Spacer()
                        if viewModel.selectedRarity == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectedRarity = nil
                    }
                    
                    ForEach(viewModel.availableRarities, id: \.self) { rarity in
                        HStack {
                            Text("\(rarity) - \(viewModel.rarityText(for: rarity))")
                            Spacer()
                            if viewModel.selectedRarity == rarity {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedRarity = rarity
                        }
                    }
                }
                
                // Danger Section
                Section("Danger Level") {
                    ForEach(viewModel.availableDangers, id: \.self) { danger in
                        HStack {
                            Text(danger)
                            Spacer()
                            if viewModel.selectedDanger == danger {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedDanger = danger
                        }
                    }
                }
                
                // Sort Section
                Section("Sort By") {
                    ForEach(viewModel.availableSortOptions, id: \.self) { sortOption in
                        HStack {
                            Text(sortOption.displayName)
                            Spacer()
                            if viewModel.filters.sortBy == sortOption {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.filters.sortBy = sortOption
                        }
                    }
                }
                
                // Sort Order Section
                Section("Sort Order") {
                    ForEach(viewModel.availableSortOrders, id: \.self) { sortOrder in
                        HStack {
                            Text(sortOrder.displayName)
                            Spacer()
                            if viewModel.filters.sortOrder == sortOrder {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.filters.sortOrder = sortOrder
                        }
                    }
                }
                
                // Action Buttons
                Section {
                    HStack {
                        Button("Clear All") {
                            viewModel.selectedCategory = "ALL"
                            viewModel.selectedRarity = nil
                            viewModel.selectedDanger = "ALL"
                            viewModel.filters = MarineFilters()
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Apply Filters") {
                            Task {
                                await viewModel.loadMarineSpecies(refresh: true)
                                dismiss()
                            }
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Extensions
extension MarineFilters.MarineSortOption {
    var displayName: String {
        switch self {
        case .name: return "Name"
        case .scientificName: return "Scientific Name"
        case .rarity: return "Rarity"
        case .size: return "Size"
        case .category: return "Category"
        case .danger: return "Danger Level"
        }
    }
}

extension MarineFilters.SortOrder {
    var displayName: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}

#Preview {
    MarineFilterView(viewModel: MarineViewModel())
}
