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
    var boundingBox: [String]
}