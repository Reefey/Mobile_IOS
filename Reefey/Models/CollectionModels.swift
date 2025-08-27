import Foundation

// MARK: - Collection Models (Legacy - keeping for backward compatibility)
struct Collection: Identifiable, Codable, Hashable {
    let id: Int
    let deviceId: String?
    let marineId: Int
    let species: String
    let scientificName: String
    let rarity: Int
    let sizeMinCm: Double?
    let sizeMaxCm: Double?
    let habitatType: [String]
    let diet: String?
    let behavior: String?
    let description: String
    let marineImageUrl: String?
    let photos: [CollectionPhoto]
    let totalPhotos: Int
    let firstSeen: String // Changed from Date to String
    let lastSeen: String // Changed from Date to String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case deviceId
        case marineId
        case species
        case scientificName
        case rarity
        case sizeMinCm
        case sizeMaxCm
        case habitatType
        case diet
        case behavior
        case description
        case marineImageUrl
        case photos
        case totalPhotos
        case firstSeen
        case lastSeen
        case status
    }
    
    // Computed properties for date conversion
    var firstSeenDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: firstSeen)
    }
    
    var lastSeenDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: lastSeen)
    }
}

struct CollectionPhoto: Codable, Hashable {
    let id: Int
    let url: String
    let annotatedUrl: String?
    let dateFound: String // Changed from Date to String
    let spotId: Int?
    let confidence: Double?
    let boundingBox: BoundingBox?
    let spots: CollectionSpot?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case annotatedUrl
        case dateFound
        case spotId
        case confidence
        case boundingBox
        case spots
    }
    
    // Computed property for date conversion
    var dateFoundDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateFound)
    }
}

// MARK: - Collection Filters
struct CollectionFilters {
    var sort: String?
    var marine: String?
    var spot: Int?
    var rarity: Int?
    var category: String?
    var danger: String?
    var venomous: String?
    
    // Convert filters to query parameters
    func toQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        
        if let sort = sort {
            queryItems.append(URLQueryItem(name: "sort", value: sort))
        }
        if let marine = marine {
            queryItems.append(URLQueryItem(name: "marine", value: marine))
        }
        if let spot = spot {
            queryItems.append(URLQueryItem(name: "spot", value: "\(spot)"))
        }
        if let rarity = rarity {
            queryItems.append(URLQueryItem(name: "rarity", value: "\(rarity)"))
        }
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        } else if category == "All" {
            queryItems.append(URLQueryItem(name: "category", value: ""))
        }
        if let danger = danger {
            queryItems.append(URLQueryItem(name: "danger", value: danger))
        }
        if let venomous = venomous {
            queryItems.append(URLQueryItem(name: "venomous", value: venomous))
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


