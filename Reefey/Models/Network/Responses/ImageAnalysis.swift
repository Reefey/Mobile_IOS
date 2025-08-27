//
//  ImageAnalysis.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct ImageAnalysis: Codable {
    let overallQuality: String
    let lightingConditions: String
    let waterClarity: String
    let depthEstimate: String
    let habitatType: String
}