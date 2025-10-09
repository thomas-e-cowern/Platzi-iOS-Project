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

private struct PresentAlertKey: EnvironmentKey {
    static let defaultValue: (AppAlert) -> Void = { _ in /* no-op */ }
}
private struct PresentNetworkErrorKey: EnvironmentKey {
    static let defaultValue: (NetworkError, String) -> Void = { _, _ in /* no-op */ }
}
private struct RunWithErrorHandlingKey: EnvironmentKey {
    static let defaultValue: (@escaping () async throws -> Void) -> Void = { _ in /* no-op */ }
}

extension EnvironmentValues {
    var presentAlert: (AppAlert) -> Void {
        get { self[PresentAlertKey.self] }
        set { self[PresentAlertKey.self] = newValue }
    }
    /// title lets you customize the alert headline per call
    var presentNetworkError: (NetworkError, String) -> Void {
        get { self[PresentNetworkErrorKey.self] }
        set { self[PresentNetworkErrorKey.self] = newValue }
    }
    /// Run an async op and auto-present any thrown errors
    var runWithErrorHandling: (@escaping () async throws -> Void) -> Void {
        get { self[RunWithErrorHandlingKey.self] }
        set { self[RunWithErrorHandlingKey.self] = newValue }
    }
}

extension EnvironmentValues {
    /// Use this everywhere while stabilizing injection. It will never crash.
    
    @MainActor
    var userSession: UserSession {
        get {
            guard let session = self[UserSessionKey.self] else {
                fatalError("UserSession missing. Inject it with `.environment(\\.userSession, session)` at the app root.")
            }
            return session
        }
        set { self[UserSessionKey.self] = newValue }
    }
    
    @MainActor
    var userSessionOptional: UserSession? {
        get { self[UserSessionKey.self] }
        set { self[UserSessionKey.self] = newValue }
    }
}
