//
//  NetworkService.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation
import Security

enum HTTPMethod {
    case get([URLQueryItem]?)   // ← allow nil to distinguish “no query”
    case post(Data?)
    case put(Data?)
    case delete

    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
}

struct Resource<T: Codable> {
    let url: URL
    var method: HTTPMethod = .get([])
    var headers: [String: String]? = nil
    var modelType: T.Type
}

struct HTTPClient {
    
    private let session: URLSession
    private let tokenStore = TokenStore()
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: configuration)
    }
    
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        do {
            return try await performRequest(resource)
        } catch NetworkError.unauthorized {
            // Attempt to refresh the token
            do {
                try await refreshToken()
                return try await performRequest(resource)
            } catch {
                throw NetworkError.unauthorized
            }
        }
    }
    
    private func performRequest<T: Codable>(_ resource: Resource<T>) async throws -> T {
        var request = URLRequest(url: resource.url)

        switch resource.method {
        case .get(let queryItems):
            if let items = queryItems, !items.isEmpty {
                var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
                components?.queryItems = items
                guard let url = components?.url else {
                    throw NetworkError.badRequest
                }
                request.url = url
            } else {
                // No query → ensure we DO NOT end with a dangling "?"
                request.url = resource.url
            }

        case .delete:
            request.httpMethod = resource.method.name

        case .post(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data

        case .put(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data
        }

        // Default headers (add these before custom headers so callers can override)
        if request.httpBody != nil && request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        // Authorization header
        if let accessToken = tokenStore.loadTokens().accessToken, !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        // Custom per-request headers (can override defaults)
        if let headers = resource.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            break
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.undefined(data, httpResponse)
        }

        do {
            // Decode as the requested model type
            return try JSONDecoder().decode(resource.modelType, from: data)
            // or: return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // Don't force-cast a String to Error; bubble the real decoding error
            throw NetworkError.decodingError(error)
        }
    }

    
    func refreshToken() async throws {
        let refreshToken =  tokenStore.loadTokens().refreshToken
        
        let body = try JSONEncoder().encode(["refreshToken": refreshToken])
        let resource = Resource(url: Constants.Urls.refresh, method: .post(body), modelType: RefreshResponse.self)
        
        let response = try await performRequest(resource)

        tokenStore.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }
}

