import Foundation
import SwiftUI

@Observable
class MarineViewModel {
    private let networkService = NetworkService.shared
    
    // MARK: - Published Properties
    var marineSpecies: [MarineSpecies] = []
    var isLoading = false
    var errorMessage: String?
    var hasMoreData = false
    var currentPage = 1
    var totalCount = 0
    
    // MARK: - Filter Properties
    var filters = MarineFilters()
    var selectedCategory: String = "ALL"
    var selectedRarity: Int?
    var selectedDanger: String = "ALL"
    var searchText = ""
    
    // MARK: - Available Filter Options
    var availableCategories: [String] = ["ALL", "Fishes", "Creatures", "Corals"]
    var availableRarities: [Int] = [1, 2, 3, 4, 5]
    var availableDangers: [String] = ["ALL", "Low", "Medium", "High", "Extreme"]
    var availableSortOptions: [MarineFilters.MarineSortOption] = MarineFilters.MarineSortOption.allCases
    var availableSortOrders: [MarineFilters.SortOrder] = MarineFilters.SortOrder.allCases
    
    // MARK: - Initialization
    init() {
        Task {
            await loadMarineSpecies()
        }
    }
    
    // MARK: - Public Methods
    @MainActor
    func loadMarineSpecies(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            marineSpecies = []
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Update filters based on current selections
            updateFilters()
            
            let response = try await networkService.fetchMarineSpecies(
                filters: filters,
                page: currentPage,
                size: 20
            )
            
            if response.success {
                if refresh {
                    marineSpecies = response.data
                } else {
                    marineSpecies.append(contentsOf: response.data)
                }
                
                totalCount = response.pagination?.total ?? 0
                hasMoreData = response.pagination?.hasNext ?? false
                currentPage += 1
            } else {
                errorMessage = response.error ?? "Failed to load marine species"
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func selectCategory(_ category: String) async {
        selectedCategory = category
        await loadMarineSpecies(refresh: true)
    }
    
    @MainActor
    func selectRarity(_ rarity: Int?) async {
        selectedRarity = rarity
        await loadMarineSpecies(refresh: true)
    }
    
    @MainActor
    func selectDanger(_ danger: String) async {
        selectedDanger = danger
        await loadMarineSpecies(refresh: true)
    }
    
    @MainActor
    func searchMarineSpecies() async {
        await loadMarineSpecies(refresh: true)
    }
    
    @MainActor
    func sortBy(_ sortOption: MarineFilters.MarineSortOption) async {
        filters.sortBy = sortOption
        await loadMarineSpecies(refresh: true)
    }
    
    @MainActor
    func sortOrder(_ order: MarineFilters.SortOrder) async {
        filters.sortOrder = order
        await loadMarineSpecies(refresh: true)
    }
    
    @MainActor
    func clearFilters() async {
        selectedCategory = "ALL"
        selectedRarity = nil
        selectedDanger = "ALL"
        searchText = ""
        filters = MarineFilters()
        await loadMarineSpecies(refresh: true)
    }
    
    // MARK: - Helper Methods
    private func updateFilters() {
        filters.category = selectedCategory == "ALL" ? nil : selectedCategory
        filters.rarity = selectedRarity
        filters.danger = selectedDanger == "ALL" ? nil : selectedDanger
        filters.searchQuery = searchText.isEmpty ? nil : searchText
    }
    
    func marineSpecies(for id: Int) -> MarineSpecies? {
        return marineSpecies.first { $0.id == id }
    }
    
    func rarityText(for rarity: Int) -> String {
        switch rarity {
        case 1: return "Very Common"
        case 2: return "Common"
        case 3: return "Uncommon"
        case 4: return "Rare"
        case 5: return "Very Rare"
        default: return "Unknown"
        }
    }
    
    func dangerColor(for danger: String) -> Color {
        switch danger.lowercased() {
        case "low": return .green
        case "medium": return .yellow
        case "high": return .orange
        case "extreme": return .red
        default: return .gray
        }
    }
    
    func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "fishes": return .blue
        case "creatures": return .purple
        case "corals": return .orange
        default: return .gray
        }
    }
    
    func sizeText(for species: MarineSpecies) -> String {
        if species.sizeMinCm == species.sizeMaxCm {
            return "\(Int(species.sizeMinCm)) cm"
        } else {
            return "\(Int(species.sizeMinCm))-\(Int(species.sizeMaxCm)) cm"
        }
    }
    
    func habitatText(for species: MarineSpecies) -> String {
        return species.habitatType.joined(separator: ", ")
    }
}
