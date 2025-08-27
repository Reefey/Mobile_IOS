import Foundation
import SwiftUI

@Observable
class CollectionsViewModel {
    private let networkService = NetworkService.shared
    
    // MARK: - Published Properties
    var collections: [MarineSpecies] = []
    var isLoading = false
    var errorMessage: String?
    var hasMoreData = false
    var currentPage = 1
    var totalCount = 0
    
    // MARK: - Filter Properties
    var filters = CollectionFilters()
    var selectedCategory: String = "ALL"
    var selectedRarity: Int?
    var selectedDanger: String = "ALL"
    var searchText = ""
    
    // MARK: - Device Manager
    private let deviceManager = DeviceManager.shared
    
    // MARK: - Available Filter Options
    var availableCategories: [String] = ["ALL", "Fishes", "Creatures", "Corals"]
    var availableRarities: [Int] = [1, 2, 3, 4, 5]
    var availableDangers: [String] = ["ALL", "Low", "Medium", "High", "Extreme"]
    var availableSortOptions: [String] = ["dateDesc", "dateAsc", "marineName", "spot", "rarity", "category", "danger"]
    
    // MARK: - Initialization
    init() {
        Task {
            await loadCollections()
        }
    }
    
    // MARK: - Public Methods
    @MainActor
    func loadCollections(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            collections = []
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Update filters based on current selections
            updateFilters()
            
            let response = try await networkService.fetchCollections(
                deviceId: deviceManager.deviceId,
                filters: filters,
                page: currentPage,
                size: 20
            )
            
            print("response", response)
            
            if response.success {
                if refresh {
                    collections = response.data
                } else {
                    collections.append(contentsOf: response.data)
                }
                
                totalCount = response.pagination?.total ?? 0
                hasMoreData = response.pagination?.hasNext ?? false
                currentPage += 1
            } else {
                // Don't show error message, just log it
                print("Failed to load collections: \(response.error ?? "Unknown error")")
            }
            
        } catch {
            // Log detailed error information
            print("Error loading collections: \(error)")
            if let networkError = error as? NetworkError {
                switch networkError {
                case .decodingError(let decodingError):
                    print("Decoding error details: \(decodingError)")
                case .httpError(let statusCode):
                    print("HTTP error with status code: \(statusCode)")
                case .invalidURL:
                    print("Invalid URL error")
                case .invalidResponse:
                    print("Invalid response error")
                case .noData:
                    print("No data received")
                case .custom(let message):
                    print("Custom error: \(message)")
                }
            }
        }
        
        isLoading = false
    }
    
    @MainActor
    func selectCategory(_ category: String) async {
        selectedCategory = category
        await loadCollections(refresh: true)
    }
    
    @MainActor
    func selectRarity(_ rarity: Int?) async {
        selectedRarity = rarity
        await loadCollections(refresh: true)
    }
    
    @MainActor
    func selectDanger(_ danger: String) async {
        selectedDanger = danger
        await loadCollections(refresh: true)
    }
    
    @MainActor
    func searchCollections() async {
        await loadCollections(refresh: true)
    }
    
    @MainActor
    func sortBy(_ sortOption: String) async {
        filters.sort = sortOption
        await loadCollections(refresh: true)
    }
    
    @MainActor
    func clearFilters() async {
        selectedCategory = "ALL"
        selectedRarity = nil
        selectedDanger = "ALL"
        searchText = ""
        filters = CollectionFilters()
        await loadCollections(refresh: true)
    }
    
    @MainActor
    func toggleFavorite(for collection: MarineSpecies) async {
        // Note: This functionality may need to be implemented differently for marine species
        // For now, we'll just log that this was called
        print("Toggle favorite called for marine species: \(collection.name)")
    }
    
    @MainActor
    func createCollection(species: String?, spotId: Int?, photo: Data, lat: Double?, lng: Double?, boundingBox: String?, notes: String?) async -> Bool {
        // Note: This functionality may need to be implemented differently for marine species
        // For now, we'll just log that this was called
        print("Create collection called for marine species")
        return false
    }
    
    @MainActor
    func deleteCollection(_ collection: MarineSpecies) async {
        // Note: This functionality may need to be implemented differently for marine species
        // For now, we'll just log that this was called
        print("Delete collection called for marine species: \(collection.name)")
    }
    
    // MARK: - Helper Methods
    private func updateFilters() {
        filters.category = selectedCategory == "ALL" ? nil : selectedCategory
        filters.rarity = selectedRarity
        filters.danger = selectedDanger == "ALL" ? nil : selectedDanger
        filters.marine = searchText.isEmpty ? nil : searchText
    }
    
    func collection(for id: Int) -> MarineSpecies? {
        return collections.first { $0.id == id }
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
    
    func sizeText(for collection: MarineSpecies) -> String {
        let minSize = collection.sizeMinCm
        let maxSize = collection.sizeMaxCm
        
        if minSize == maxSize {
            return "\(minSize) cm"
        } else {
            return "\(minSize)-\(maxSize) cm"
        }
    }
    
    func habitatText(for collection: Collection) -> String {
        return collection.habitatType.joined(separator: ", ")
    }
}
