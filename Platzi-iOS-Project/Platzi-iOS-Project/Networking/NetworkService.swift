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
        print("Login response: \(response)")
        print("Login data: \(data)")
        print(String(decoding: data, as: UTF8.self))
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
}

//let parameters = "{\r\n\t\"email\": \"john@mail.com\",\r\n\t\"password\": \"changeme\"\r\n}"
//let postData = parameters.data(using: .utf8)
//
//var request = URLRequest(url: URL(string: "https://api.escuelajs.co/api/v1/auth/login")!,timeoutInterval: Double.infinity)
//request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//request.httpMethod = "POST"
//request.httpBody = postData
//
//let task = URLSession.shared.dataTask(with: request) { data, response, error in
//  guard let data = data else {
//    print(String(describing: error))
//    return
//  }
//  print(String(data: data, encoding: .utf8)!)
//}
//
//task.resume()
