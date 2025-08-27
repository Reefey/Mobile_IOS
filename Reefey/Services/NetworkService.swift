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
        
        // Log curl command for debugging
        var curlCommand = "curl -X \(method.rawValue)"
        curlCommand += " '\(url.absoluteString)'"
        curlCommand += " -H 'Content-Type: application/json'"
        if let bodyData = body, let bodyString = String(data: bodyData, encoding: .utf8) {
            let escapedBody = bodyString.replacingOccurrences(of: "'", with: "'\"'\"'")
            curlCommand += " -d '\(escapedBody)'"
        }
        print("Curl command: \(curlCommand)")
        print("---")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("HTTP Error \(httpResponse.statusCode): \(responseBody)")
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            print("Response JSON: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch let decodingError {
                print("Decoding error: \(decodingError)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                throw NetworkError.decodingError(decodingError)
            }
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
    ) async throws -> MarineResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        if let filters = filters {
            queryItems.append(contentsOf: filters.toQueryItems())
        }
        
        return try await request(
            endpoint: "/marine/all/\(deviceId)",
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
    
    func analyzePhoto(deviceId: String, photo: String) async throws -> APIResponse<AnalyzePhotoData> {
        let req = AnalyzePhotoRequest(deviceId: deviceId, photo: photo)
        let encoder = JSONEncoder()
        let body = try encoder.encode(req)
        return  try await request(
            endpoint: "/ai/analyze-photo-base64",
            method: .POST,
            body: body
        )
    }
    
    func batchIdentify(deviceId: String, photos: [String]) async throws -> APIResponse<BatchIdentifyData> {
        let req = BatchIdentifyRequest(deviceId: deviceId, photos: photos)
        let encoder = JSONEncoder()
        let body = try encoder.encode(req)
        return try await request(
            endpoint: "/ai/batch-identify-base64",
            method: .POST,
            body: body
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
    case custom(String)
    
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
        case .custom(let message):
            return message
        }
    }
}

struct EmptyResponse: Codable {}
