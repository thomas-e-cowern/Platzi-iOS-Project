//
//  UserSessionKey.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/9/25.
//

import Foundation
import SwiftUI

// 1) The key stores an *optional* to avoid constructing on a nonisolated context.
struct UserSessionKey: EnvironmentKey {
    static let defaultValue: UserSession? = nil
}
