//
//  AuthenticationService.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation

struct AuthenticationService {
    let httpClient: HTTPClient
    let tokenStore = TokenStore()
    
    func register(name: String, email: String, password: String, role: String = "customer", avatar: String = "https://avatar.iran.liara.run/public/9") async throws -> RegistrationResponse {
        print("in register in AuthenticationService")
        let request = RegistrationRequest(name: name, email: email, password: password, role: role, avatar: avatar)
        let registrationResponse = try await httpClient.register(request: request)
        print("\(registrationResponse)")
        return registrationResponse
    }
    
    func login(email: String, password: String) async throws -> Bool {
        print("In login in AuthenticationService")
        let loginResponse = try await httpClient.login(email: email, password: password)
        
        print("Login accessToken: \(loginResponse.accessToken)")
        print("Login refreshToken: \(loginResponse.refreshToken)")
        
        // Save the token
        tokenStore.saveTokens(accessToken: loginResponse.accessToken, refreshToken: loginResponse.refreshToken)
        
        return false
    }
}
