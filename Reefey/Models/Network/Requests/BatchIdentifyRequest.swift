//
//  BatchIdentifyRequest.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import Foundation

struct BatchIdentifyRequest: Codable {
    let deviceId: String
    let photos: [String]  // Array of base64 encoded images
    
    init(deviceId: String, photos: [String]) {
        self.deviceId = deviceId
        self.photos = photos
    }
}
