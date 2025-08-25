import Foundation
import SwiftUI

@Observable
class CollectionDetailViewModel {
    private let networkService = NetworkService.shared
    
    // MARK: - Published Properties
    var collection: Collection?
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Device ID (should be generated or stored securely)
    private let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "default-device-id"
    
    // MARK: - Public Methods
    @MainActor
    func loadCollectionDetail(deviceId: String, id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkService.fetchCollectionDetail(deviceId: deviceId, id: id)
            if response.success {
                collection = response.data
            } else {
                errorMessage = response.error ?? "Failed to load collection detail"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func updateCollection(
        deviceId: String,
        id: Int,
        species: String? = nil,
        spotId: Int? = nil,
        notes: String? = nil
    ) async -> Bool {
        do {
            let request = UpdateCollectionRequest(
                species: species,
                spotId: spotId,
                notes: notes
            )
            
            let updatedCollection = try await networkService.updateCollection(deviceId: deviceId, id: id, request)
            collection = updatedCollection
            return true
        } catch {
            errorMessage = "Failed to update collection: \(error.localizedDescription)"
            return false
        }
    }
    
    @MainActor
    func toggleFavorite() async {
        guard let collection = collection else { return }
        
        do {
            let updatedCollection = try await networkService.toggleFavorite(deviceId: deviceId, id: collection.id)
            self.collection = updatedCollection
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func deleteCollection() async -> Bool {
        guard let collection = collection else { return false }
        
        do {
            try await networkService.deleteCollection(deviceId: deviceId, id: collection.id)
            return true
        } catch {
            errorMessage = "Failed to delete collection: \(error.localizedDescription)"
            return false
        }
    }
}
