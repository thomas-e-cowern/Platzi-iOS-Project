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

// MARK: - LoginRequest
struct LoginRequest: Codable {
    let email, password: String
}

// MARK: - LoginResponse
struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

// MARK: = RefreshResponse
struct RefreshResponse: Codable {
    let accessToken: String
    let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

// MARK: - ErrorResponse
struct ErrorResponse: Codable {
    let message: String?
}

// MARK: - Categories
struct Category: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let image: String
}

// MARK: - AddCategory
struct AddCategory: Codable {
    let name: String
    let image: String
}

// MARK: - Product
struct Product: Codable {
    let id: Int
    let title, slug: String
    let price: Int
    let description: String
    let category: Category
    let images: [String]
}
