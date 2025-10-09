//
//  View+Extensions.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/9/25.
//

import SwiftUI

struct RoleRestricted: ViewModifier {
    @Environment(\.userSession) private var session
    let allowed: Set<UserRole>

    func body(content: Content) -> some View {
        Group {
            if allowed.contains(session.role) {
                content
            }
        }
    }
}

extension View {
    func visible(onlyFor roles: UserRole...) -> some View {
        modifier(RoleRestricted(allowed: Set(roles)))
    }
}

