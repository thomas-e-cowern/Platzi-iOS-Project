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
        var request = URLRequest(url: URL(string: "https://api.escuelajs.co/api/v1/users/")!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(registrationRequest)

        let (data, response) = try await URLSession.shared.data(for: request)
        let registrationResponse = try JSONDecoder().decode(RegistrationResponse.self, from: data)

        return registrationResponse
    }
}
