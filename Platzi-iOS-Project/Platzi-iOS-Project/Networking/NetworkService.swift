//
//  NetworkService.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation
import Security

enum HTTPMethod {
    case get([URLQueryItem])
    case post(Data?)
    case delete
    case put(Data?)
    
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .delete:
            return "DELETE"
        case .put:
            return "PUT"
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
            var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems
            guard let url = components?.url else {
                throw NetworkError.badRequest
            }
            request.url = url
        case .delete:
            request.httpMethod = resource.method.name
        case .post(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data
        case .put(let data):
            request.httpMethod = resource.method.name
            request.httpBody = data
        }
        
        // add authorizaion header: accessToken
        if let accessToken = tokenStore.loadTokens().accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
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
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        default:
            throw NetworkError.undefined(data, httpResponse)
        }
        
        do {
            return try JSONDecoder().decode(resource.modelType, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription as! Error)
        }
        
    }
}

