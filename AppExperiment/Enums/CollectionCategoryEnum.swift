//
//  CollectionCategoryEnum.swift
//  AppExperiment
//
//  Created by Reza Juliandri on 23/08/25.
//

enum CollectionCategoryEnum: String, CaseIterable {
    case ALL = "All"
    case FISH = "Fish"
    case CREATURES = "Creatures"
    case CORALS = "Corals"
    case UNKNOWN = "Unknown"
    
    var description: String { rawValue }
}
