//
//  BatchIdentifyData.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct BatchIdentifyData: Codable {
    let results: [BatchIdentifyResult]
    let totalProcessed: Int
    let successfulIdentifications: Int
    let failedIdentifications: Int
}

struct BatchIdentifyResult: Codable {
    let photoIndex: Int
    let photoAssetIdentifier: String
    let success: Bool
    let marineData: MarineData?
    let error: String?
    let detections: [Detection]?
    let unknownSpecies: [UnknownSpecies]?
    let originalPhotoUrl: String?
    let annotatedPhotoUrl: String?
}
