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
    
    func register(name: String, email: String, password: String, role: String = "customer", avatar: String) async throws -> RegistrationResponse {
        print("Avatar: \(avatar)")
        let request = RegistrationRequest(name: name, email: email, password: password, role: role, avatar: avatar)
        
        let resource = Resource(url: Constants.Urls.register, method: .post(try request.encode()), modelType: RegistrationResponse.self)
        
        let registrationResponse = try await httpClient.load(resource)
        
        print("Registration response: \(registrationResponse)")
        
        return registrationResponse
    }
    
    func login(email: String, password: String) async throws -> Bool {

        let request = LoginRequest(email: email, password: password)
        
        let resource = Resource(url: Constants.Urls.login, method: .post(try request.encode()), modelType: LoginResponse.self)
        
        let loginResponse = try await httpClient.load(resource)
        print("Login response: \(loginResponse)")
        // Save the token
        tokenStore.saveTokens(accessToken: loginResponse.accessToken, refreshToken: loginResponse.refreshToken)
        
        print("Log in successful!")
        
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
    
    func getUserProfile() async throws -> UserProfile {
        // 1) Get and sanitize token (and fail fast if missing)
        guard let rawToken = tokenStore.loadTokens().accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawToken.isEmpty
        else {
            throw NetworkError.unauthorized // or your own MissingToken error
        }

        // Strip accidental quotes if the token was JSON-encoded as a string
        let token = rawToken.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))

        // Optional: safer logging (don’t print full token)
        let tail = String(token.suffix(8))
        print("Using access token …\(tail)")

        // 2) NO query items → use .get(nil) so we don’t end with “?”
        let resource = Resource(
            url: Constants.Urls.getProfile,        // make sure this is ".../auth/profile" (no "?")
            method: .get(nil),                     // <-- important: NOT .get([])
            headers: [
                "Accept": "application/json",
                "Authorization": "Bearer \(token)"
            ],
            modelType: UserProfile.self
        )

        // 3) Load
        let userProfile = try await httpClient.load(resource)
        return userProfile
    }
    
    func probeProfileDirect() async {
        do {
            let token = try sanitizedToken()
            var req = URLRequest(url: URL(string: "https://api.escuelajs.co/api/v1/auth/profile")!)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, resp) = try await URLSession.shared.data(for: req)
            let http = resp as! HTTPURLResponse
            print("STATUS:", http.statusCode)
            print("BODY:", String(data: data, encoding: .utf8) ?? "<non-utf8>")

        } catch {
            print("Probe error:", error)
        }
    }
    
    func sanitizedToken() throws -> String {
        guard let raw = tokenStore.loadTokens().accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            throw NetworkError.unauthorized
        }
        // If token was JSON-encoded with quotes, strip them: "\"eyJ…\"" → "eyJ…"
        return raw.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
    }

}
