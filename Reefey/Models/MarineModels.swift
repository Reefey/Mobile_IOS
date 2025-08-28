import Foundation

// MARK: - Marine Species Models
struct MarineSpecies: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let scientificName: String
    let category: String
    let rarity: Int
    let sizeMinCm: Double?
    let sizeMaxCm: Double?
    let habitatType: [String]
    let diet: String?
    let behavior: String?
    let danger: String
    let venomous: Bool
    let description: String
    let imageUrl: String?
    let lifeSpan: String?
    let reproduction: String?
    let migration: String?
    let endangered: String?
    let funFact: String?
    let foundAtSpots: [MarineSpot]?
    let totalSpots: Int?
    let edibility: Bool?
    let poisonous: Bool?
    let endangeredd: Bool?
    let inUserCollection: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case scientificName = "scientificName"
        case category
        case rarity
        case sizeMinCm = "sizeMinCm"
        case sizeMaxCm = "sizeMaxCm"
        case habitatType = "habitatType"
        case diet
        case behavior
        case danger
        case venomous
        case description
        case imageUrl
        case lifeSpan
        case reproduction
        case migration
        case endangered
        case funFact
        case foundAtSpots
        case totalSpots
        case edibility
        case poisonous
        case endangeredd
        case inUserCollection
    }
}

struct MarineSpot: Codable, Hashable {
    let spotId: Int
    let frequency: String
    let seasonality: String
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case spotId
        case frequency
        case seasonality
        case notes
    }
}

// MARK: - Marine API Response Models
struct MarineResponse: Codable {
    let success: Bool
    let data: [MarineSpecies]
    let message: String?
    let error: String?
    let pagination: MarinePagination?
}

struct MarinePagination: Codable {
    let total: Int
    let page: Int
    let size: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrevious: Bool
    
    enum CodingKeys: String, CodingKey {
        case total
        case page
        case size
        case totalPages
        case hasNext
        case hasPrevious
    }
}

// MARK: - Marine Filter Models
struct MarineFilters {
    var category: String?
    var rarity: Int?
    var danger: String?
    var habitatType: String?
    var searchQuery: String?
    var sortBy: MarineSortOption = .name
    var sortOrder: SortOrder = .ascending
    
    enum MarineSortOption: String, CaseIterable {
        case name = "name"
        case scientificName = "scientificName"
        case rarity = "rarity"
        case size = "size"
        case category = "category"
        case danger = "danger"
    }
    
    enum SortOrder: String, CaseIterable {
        case ascending = "asc"
        case descending = "desc"
    }
    
    // Convert filters to query parameters
    func toQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "filterCategory", value: category))
        }
        if let rarity = rarity {
            queryItems.append(URLQueryItem(name: "filterRarity", value: "\(rarity)"))
        }
        if let danger = danger {
            queryItems.append(URLQueryItem(name: "filterDanger", value: danger))
        }
        if let habitatType = habitatType {
            queryItems.append(URLQueryItem(name: "filterHabitat", value: habitatType))
        }
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: searchQuery))
        }
        queryItems.append(URLQueryItem(name: "sort", value: sortBy.rawValue))
        queryItems.append(URLQueryItem(name: "order", value: sortOrder.rawValue))
        
        return queryItems
    }
}

// MARK: - Marine Category Models
struct MarineCategory: Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case count
    }
}

// MARK: - Marine Detail Models
struct MarineDetail: Codable {
    let success: Bool
    let data: MarineSpecies
    let message: String?
    let error: String?
}

// MARK: - Marine Create Request
struct CreateMarineRequest: Codable {
    let name: String
    let scientificName: String
    let category: String
    let rarity: Int
    let sizeMinCm: Double?
    let sizeMaxCm: Double?
    let habitatType: [String]
    let diet: String?
    let behavior: String?
    let danger: String
    let venomous: Bool
    let description: String
    let lifeSpan: String?
    let reproduction: String?
    let migration: String?
    let endangered: String?
    let funFact: String?
    let edibility: Bool?
    let poisonous: Bool?
    let endangeredd: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case scientificName = "scientificName"
        case category
        case rarity
        case sizeMinCm = "sizeMinCm"
        case sizeMaxCm = "sizeMaxCm"
        case habitatType = "habitatType"
        case diet
        case behavior
        case danger
        case venomous
        case description
        case lifeSpan
        case reproduction
        case migration
        case endangered
        case funFact
        case edibility
        case poisonous
        case endangeredd
    }
}
