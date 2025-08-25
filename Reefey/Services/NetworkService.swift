import Foundation

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://586b5915665f.ngrok-free.app/api" // Real API base URL
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Generic Request Method
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            // print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Marine API Methods
    func fetchMarineSpecies(
        filters: MarineFilters? = nil,
        page: Int = 1,
        size: Int = 50
    ) async throws -> MarineResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        if let filters = filters {
            queryItems.append(contentsOf: filters.toQueryItems())
        }
        
        return try await request(
            endpoint: "/marine",
            queryItems: queryItems
        )
    }
    
    func fetchMarineSpeciesDetail(id: Int) async throws -> MarineDetail {
        return try await request(endpoint: "/marine/\(id)")
    }
    
    func createMarineSpecies(_ createRequest: CreateMarineRequest) async throws -> MarineSpecies {
        let encoder = JSONEncoder()
        let body = try encoder.encode(createRequest)
        
        let response: MarineDetail = try await request(
            endpoint: "/marine",
            method: .POST,
            body: body
        )
        return response.data
    }
    
    func deleteMarineSpecies(id: Int) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/marine/\(id)",
            method: .DELETE
        )
    }
    
    // MARK: - Collections API Methods
    func fetchCollections(
        deviceId: String,
        filters: CollectionFilters? = nil,
        page: Int = 1,
        size: Int = 50
    ) async throws -> CollectionsResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        if let filters = filters {
            if let sort = filters.sort {
                queryItems.append(URLQueryItem(name: "sort", value: sort))
            }
            if let filterMarine = filters.filterMarine {
                queryItems.append(URLQueryItem(name: "filterMarine", value: filterMarine))
            }
            if let filterSpot = filters.filterSpot {
                queryItems.append(URLQueryItem(name: "filterSpot", value: "\(filterSpot)"))
            }
            if let filterRarity = filters.filterRarity {
                queryItems.append(URLQueryItem(name: "filterRarity", value: "\(filterRarity)"))
            }
            if let filterCategory = filters.filterCategory {
                queryItems.append(URLQueryItem(name: "filterCategory", value: filterCategory))
            }
            if let filterDanger = filters.filterDanger {
                queryItems.append(URLQueryItem(name: "filterDanger", value: filterDanger))
            }
            if let filterDateFrom = filters.filterDateFrom {
                queryItems.append(URLQueryItem(name: "filterDateFrom", value: filterDateFrom))
            }
            if let filterDateTo = filters.filterDateTo {
                queryItems.append(URLQueryItem(name: "filterDateTo", value: filterDateTo))
            }
        }
        
        return try await request(
            endpoint: "/collections/\(deviceId)",
            queryItems: queryItems
        )
    }
    
    func fetchCollectionDetail(deviceId: String, id: Int) async throws -> CollectionDetail {
        return try await request(endpoint: "/collections/\(deviceId)/\(id)")
    }
    
    func createCollection(deviceId: String, _ createRequest: CreateCollectionRequest) async throws -> Collection {
        let encoder = JSONEncoder()
        let body = try encoder.encode(createRequest)
        
        return try await request(
            endpoint: "/collections/\(deviceId)",
            method: .POST,
            body: body
        )
    }
    
    func updateCollection(deviceId: String, id: Int, _ updateRequest: UpdateCollectionRequest) async throws -> Collection {
        let encoder = JSONEncoder()
        let body = try encoder.encode(updateRequest)
        
        return try await request(
            endpoint: "/collections/\(deviceId)/\(id)",
            method: .PUT,
            body: body
        )
    }
    
    func deleteCollection(deviceId: String, id: Int) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/collections/\(deviceId)/\(id)",
            method: .DELETE
        )
    }
    
    func toggleFavorite(deviceId: String, id: Int) async throws -> Collection {
        return try await request(
            endpoint: "/collections/\(deviceId)/\(id)/favorite",
            method: .POST
        )
    }
}

// MARK: - Supporting Types
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        }
    }
}

struct EmptyResponse: Codable {}
