//
//  DataTransferObjects.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation

// MARK: - User
struct RegistrationResponse: Codable {
    let email, password, name: String
    let avatar: String
    let role: String
    let id: Int
}

// MARK: - RegistrationRequest
struct RegistrationRequest: Codable {
    let name, email, password: String
    let role: String
    let avatar: String
}
