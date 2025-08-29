//
//  Encodable+Extensions.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/29/25.
//

import Foundation

extension Encodable {
    func encode () throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
