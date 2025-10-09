//
//  UserSession.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/9/25.
//

import Foundation
import Combine

enum UserRole: String, Codable, CaseIterable, Equatable {
    case admin, customer
}

@Observable
@MainActor
final class UserSession {
    private enum Keys {
        static let userRole = "userRole"
    }

   private(set) var role: UserRole

    init() {
        let saved = UserDefaults.standard.string(forKey: Keys.userRole)
        self.role = UserRole(rawValue: saved ?? "") ?? .customer
    }

    func updateRole(_ newRole: UserRole) {
        guard role != newRole else { return }
        role = newRole
        UserDefaults.standard.set(newRole.rawValue, forKey: Keys.userRole)
    }
}
