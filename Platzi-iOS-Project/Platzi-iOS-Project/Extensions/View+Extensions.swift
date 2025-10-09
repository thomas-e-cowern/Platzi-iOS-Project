//
//  View+Extensions.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/9/25.
//

import SwiftUI

struct RoleRestricted: ViewModifier {
    @Environment(\.userSessionOptional) private var session
    let allowed: Set<UserRole>

    func body(content: Content) -> some View {
        if let role = session?.role, allowed.contains(role) {
            content
        } else {
            EmptyView()
        }
    }
}

extension View {
    func visible(onlyFor roles: UserRole...) -> some View {
        modifier(RoleRestricted(allowed: Set(roles)))
    }
}
