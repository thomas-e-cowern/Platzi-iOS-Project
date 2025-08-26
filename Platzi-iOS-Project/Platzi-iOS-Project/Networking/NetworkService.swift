//
//  NetworkService.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation

struct HTTPClient {
    func register(request: RegistrationRequest) async throws -> RegistrationResponse {

        let registrationRequest = request
        var request = URLRequest(url: Constants.Urls.register)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(registrationRequest)

        let (data, response) = try await URLSession.shared.data(for: request)
        let registrationResponse = try JSONDecoder().decode(RegistrationResponse.self, from: data)

        return registrationResponse
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        
        var request = URLRequest(url: Constants.Urls.login)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(loginRequest)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)

        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
}

