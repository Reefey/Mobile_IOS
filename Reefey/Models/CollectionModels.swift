import Foundation

// MARK: - Collection Models
struct Collection: Identifiable, Codable, Hashable {
    let id: Int
    let name: String?
    let scientificName: String?
    let category: String?
    let rarity: Int?
    let sizeMinCm: Double?
    let sizeMaxCm: Double?
    let habitatType: [String]?
    let diet: String?
    let behavior: String?
    let danger: String?
    let venomous: Bool?
    let description: String?
    let lifeSpan: String?
    let reproduction: String?
    let migration: String?
    let endangered: String?
    let funFact: String?
    let imageUrl: String?
    let edibility: Bool?
    let poisonous: Bool?
    let endangeredd: Bool?
    let createdAt: String?
    let updatedAt: String?
    let inUserCollection: Bool?
    let hasAnalyzedPhotos: Bool?
    let lastSeen: String?
    let firstSeen: String?
    let totalPhotos: Int?
    let userPhotos: [CollectionPhoto]?
    let collectionId: Int?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case scientificName
        case category
        case rarity
        case sizeMinCm
        case sizeMaxCm
        case habitatType
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
        case imageUrl
        case edibility
        case poisonous
        case endangeredd
        case createdAt
        case updatedAt
        case inUserCollection
        case hasAnalyzedPhotos
        case lastSeen
        case firstSeen
        case totalPhotos
        case userPhotos
        case collectionId
        case status
    }
    
    // Computed properties for backwards compatibility
    var species: String { name ?? "Unknown" }
    var marineImageUrl: String? { imageUrl }
    var photos: [CollectionPhoto] { userPhotos ?? [] }
    
    // Computed properties for date conversion
    var firstSeenDate: Date? {
        guard let firstSeen = firstSeen else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: firstSeen)
    }
    
    var lastSeenDate: Date? {
        guard let lastSeen = lastSeen else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: lastSeen)
    }
}

struct CollectionPhoto: Codable, Hashable {
    let id: Int?
    let url: String?
    let annotatedUrl: String?
    let dateFound: String?
    let spotId: Int?
    let confidence: Double?
    let boundingBox: BoundingBox?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case annotatedUrl
        case dateFound
        case spotId
        case confidence
        case boundingBox
        case notes
    }
    
    // Computed property for date conversion
    var dateFoundDate: Date? {
        guard let dateFound = dateFound else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateFound)
    }
}

struct BoundingBox: Codable, Hashable {
    let x: Double?
    let y: Double?
    let width: Double?
    let height: Double?
}

struct CollectionSpot: Codable, Hashable {
    let name: String
    let lat: Double
    let lng: Double
}

// MARK: - Collection Filters
struct CollectionFilters {
    var sort: String?
    var filterMarine: String?
    var filterSpot: Int?
    var filterRarity: Int?
    var category: String?
    var filterDanger: String?
    var filterDateFrom: String?
    var filterDateTo: String?
    
    // Convert filters to query parameters
    func toQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        if let sort = sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort))
        }
        if let filterMarine = filterMarine {
            queryItems.append(URLQueryItem(name: "filterMarine", value: filterMarine))
        }
        if let filterSpot = filterSpot {
            queryItems.append(URLQueryItem(name: "filterSpot", value: "\(filterSpot)"))
        }
        if let filterRarity = filterRarity {
            queryItems.append(URLQueryItem(name: "filterRarity", value: "\(filterRarity)"))
        }
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let filterDanger = filterDanger {
            queryItems.append(URLQueryItem(name: "filterDanger", value: filterDanger))
        }
        if let filterDateFrom = filterDateFrom {
            queryItems.append(URLQueryItem(name: "filterDateFrom", value: filterDateFrom))
        }
        if let filterDateTo = filterDateTo {
            queryItems.append(URLQueryItem(name: "filterDateTo", value: filterDateTo))
        }
        
        return queryItems
    }
}

struct CollectionDetail: Codable {
    let success: Bool
    let data: Collection
    let message: String?
    let error: String?
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct CollectionsResponse: Codable {
    let success: Bool
    let data: [Collection]
    let message: String?
    let error: String?
    let pagination: CollectionPagination?
}

struct CollectionPagination: Codable {
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

// MARK: - Request Models
struct CreateCollectionRequest: Codable {
    let species: String?
    let spotId: Int?
    let photo: Data
    let lat: Double?
    let lng: Double?
    let boundingBox: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case species
        case spotId
        case photo
        case lat
        case lng
        case boundingBox
        case notes
    }
}

struct UpdateCollectionRequest: Codable {
    let species: String?
    let spotId: Int?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case species
        case spotId
        case notes
    }
}


