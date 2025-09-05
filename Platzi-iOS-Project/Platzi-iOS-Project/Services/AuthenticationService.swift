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

        let request = RegistrationRequest(name: name, email: email, password: password, role: role, avatar: avatar)
        
        let resource = Resource(url: Constants.Urls.register, method: .post(try request.encode()), modelType: RegistrationResponse.self)
        
        let registrationResponse = try await httpClient.load(resource)

        return registrationResponse
    }
    
    func login(email: String, password: String) async throws -> Bool {

        let request = LoginRequest(email: email, password: password)
        
        let resource = Resource(url: Constants.Urls.login, method: .post(try request.encode()), modelType: LoginResponse.self)
        
        let loginResponse = try await httpClient.load(resource)

        // Save the token
        tokenStore.saveTokens(accessToken: loginResponse.accessToken, refreshToken: loginResponse.refreshToken)
        
        return true
    }
    
    func signout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        tokenStore.clearTokens()
    }
    
    func checkLoggedInStatus() async -> Bool {
        guard let accessToken = tokenStore.loadTokens().accessToken else {
            print("No access token")
            return false
        }
        
        // Is accessToken expired?
        if JWT.isExpired(accessToken) {
            do {
                print("Refreshing token")
                try await httpClient.refreshToken()
                return true
            } catch {
                print("Error checking logged in status: \(error.localizedDescription)")
                return false
            }
            
        } else {
            return true
        }
    }
}
