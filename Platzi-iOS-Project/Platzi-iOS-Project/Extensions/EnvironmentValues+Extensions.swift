//
//  EnvironmentValues+Extensions.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var authenticationService = AuthenticationService(httpClient: HTTPClient())
}
