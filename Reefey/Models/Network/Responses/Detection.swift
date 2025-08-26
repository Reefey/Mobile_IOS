//
//  Detection.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct Detection: Codable {
    var species: String
    var scientificName: String?  // Optional since API doesn't always provide it
    var confidence: Double
    var confidenceReasoning: String?
    var wasInDatabase: Bool
    var databaseId: Int?
    var description: String?
    var behavioralNotes: String?
    var sizeEstimate: String?
    var habitatContext: String?
    var interactions: String?
    var imageQuality: String?
    var instances: [Instance]
}