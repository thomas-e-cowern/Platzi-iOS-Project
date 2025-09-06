//
//  Constatns.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/26/25.
//

import Foundation

struct Constants {
    
    struct Urls {
        static let register = URL(string: "https://api.escuelajs.co/api/v1/users/")!
        static let login = URL(string: "https://api.escuelajs.co/api/v1/auth/login")!
        static let refresh = URL(string: "https://api.escuelajs.co/api/v1/auth/refresh-token")!
        static let categorites = URL(string: "https://api.escuelajs.co/api/v1/categories")!
    }
}
