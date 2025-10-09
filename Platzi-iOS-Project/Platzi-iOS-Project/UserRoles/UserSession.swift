//
//  UserSession.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/9/25.
//

import SwiftUI
import Combine

enum UserRole: String, Codable, CaseIterable, Equatable {
    case employee
    case customer
}

@Observable
@MainActor
final class UserSession {
    /// Persist the role across launches
    @AppStorage("userRole") private var storedRole: String = UserRole.customer.rawValue

    private(set) var role: UserRole = .customer

    init() {
        role = UserRole(rawValue: storedRole) ?? .customer
    }

    func updateRole(_ newRole: UserRole) {
        guard role != newRole else { return }
        role = newRole
        storedRole = newRole.rawValue
    }
}

