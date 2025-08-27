//
//  CollectionEntry.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct CollectionEntry: Codable {
    var id: Int
    var species: String
    var status: String
    var photoUrl: String
    var boundingBox: BoundingBox
    var marineData: MarineData?
}

struct MarineData: Codable {
    let id: Int
    let name: String
    let scientificName: String
    let category: String
    let rarity: Int
    let sizeMinCm: Int?
    let sizeMaxCm: Int?
    let habitatType: [String]?
    let diet: String?
    let behavior: String?
    let danger: String
    let venomous: Bool?
    let description: String
    let lifeSpan: String?
    let reproduction: String?
    let migration: String?
    let endangered: String?
    let endangeredd: Bool?
    let edibility: Bool?
    let poisonous: Bool?
    let funFact: String?
    let imageUrl: String?
    let createdAt: String
    let updatedAt: String
}
