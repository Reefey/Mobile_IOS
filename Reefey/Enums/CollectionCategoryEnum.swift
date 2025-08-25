//
//  CollectionCategoryEnum.swift
//  Reefey
//
//  Created by Reza Juliandri on 23/08/25.
//

enum CollectionCategoryEnum: String, CaseIterable {
    case ALL = "All"
    case FISHES = "Fishes"
    case CREATURES = "Creatures"
    case CORALS = "Corals"
    case UNKNOWN = "Unknown"
    
    var description: String { rawValue }
}
