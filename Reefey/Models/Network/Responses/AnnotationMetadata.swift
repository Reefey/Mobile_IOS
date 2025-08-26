//
//  AnnotationMetadata.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct AnnotationMetadata: Codable {
    let totalDetections: Int
    let identifiedSpecies: Int
    let unknownSpecies: Int
    let averageConfidence: Double
    let annotationQuality: String
    let processingNotes: String
}