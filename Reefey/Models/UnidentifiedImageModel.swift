//
//  UnidentifiedImageModel.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//


import SwiftData
import Foundation

// MARK: - SwiftData Models
@Model
class UnidentifiedImageModel {
    var photoAssetIdentifier: String  // PHAsset local identifier
    var dateTaken: Date
    var isProcessed: Bool
    
    init(photoAssetIdentifier: String, dateTaken: Date, isProcessed: Bool = false) {
        self.photoAssetIdentifier = photoAssetIdentifier
        self.dateTaken = dateTaken
        self.isProcessed = isProcessed
    }
}
