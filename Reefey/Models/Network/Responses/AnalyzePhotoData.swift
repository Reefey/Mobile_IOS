//
//  AnalyzePhotoData.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct AnalyzePhotoData: Codable {
    let detections: [Detection]
    let unknownSpecies: [UnknownSpecies]
    let originalPhotoUrl: String
    let annotatedPhotoUrl: String?  // Optional annotated photo URL
    let collectionEntries: [CollectionEntry]
    let imageAnalysis: ImageAnalysis?
    let annotationMetadata: AnnotationMetadata?
}