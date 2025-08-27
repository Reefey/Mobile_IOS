//
//  UnknownSpecies.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct UnknownSpecies: Codable {
    var description: String
    var behavioralNotes: String?
    var sizeCharacteristics: String?
    var colorPatterns: String?
    var habitatPosition: String?
    var similarSpecies: [String]?
    var gptResponse: String
    var confidence: Double
    var confidenceReasoning: String?
    var instances: [Instance]
}