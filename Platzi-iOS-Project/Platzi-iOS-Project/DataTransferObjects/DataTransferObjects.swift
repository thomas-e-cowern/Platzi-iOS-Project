//
//  DataTransferObjects.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation
import MapKit

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

// MARK: - UserProfileRequest
struct UserProfileRequest: Codable {
    let authorization: String
}

struct UserProfile: Codable {
    let id: Int
    let name, email, password: String
    let role: String
    let avatar: String
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
//struct ErrorResponse: Codable {
//    let message: String?
//}

struct ErrorResponse: Codable {
    let message: String?
    let error: String?
    let statusCode: Int?
    let details: String?
}

// MARK: - Categories
struct Category: Codable, Identifiable, Equatable {
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
struct Product: Codable, Identifiable, Equatable {
    let id: Int
    let title, slug: String
    let price: Int
    let description: String
    let category: Category
    let images: [String]
    
    // Local-only, dynamic cart quantity
    var quantityOrdered: Int = 1
    
    // ✅ Exclude quantityOrdered so Codable ignores it
    private enum CodingKeys: String, CodingKey {
        case id, title, slug, price, description, category, images
    }
}

// MARK: - AddProduct
struct AddProduct: Codable {
    let title: String
    let price: Int
    let description: String
    let categoryId: Int
    let images: [String]
}

// MARK: - Location
struct Location: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - PreviewProduct
extension Product {
    static var preview: Product {
        Product(id: 86, title: "Classic Red Pullover Hoodie", slug: "classic-red-pullover-hoodie", price: 10, description: "Elevate your casual wardrobe with our Classic Red Pullover Hoodie. Crafted with a soft cotton blend for ultimate comfort, this vibrant red hoodie features a kangaroo pocket, adjustable drawstring hood, and ribbed cuffs for a snug fit. The timeless design ensures easy pairing with jeans or joggers for a relaxed yet stylish look, making it a versatile addition to your everyday attire.", category: Category(id: 31, name: "Clothes", slug: "clothes", image: "https://i.imgur.com/QkIa5tT.jpeg"),
                images:
                    [
                        "https://i.imgur.com/1twoaDy.jpeg",
                        "https://i.imgur.com/FDwQgLy.jpeg",
                        "https://i.imgur.com/kg1ZhhH.jpeg"
                    ]
        )
    }
}
