//
//  String+.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

extension String {
    func asPNGBaseURLString() -> String {
        return "data:image/png;base64,\(self)"
    }
    func asJPGBaseURLString() -> String {
        return "data:image/jpeg;base64,\(self)"
    }
}
