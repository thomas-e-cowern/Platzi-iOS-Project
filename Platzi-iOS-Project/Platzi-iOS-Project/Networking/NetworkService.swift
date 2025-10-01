//
//  NetworkService.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import Foundation
import Security

enum HTTPMethod {
    case get([URLQueryItem]?)   // allow nil to mean "no query"
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
    var method: HTTPMethod = .get(nil) // default: NO query (prevents `/path?`)
    var headers: [String: String]? = nil
    var modelType: T.Type
}

struct HTTPClient {

    private let session: URLSession
    private let tokenStore = TokenStore()

    init() {
        let configuration = URLSessionConfiguration.default
        // Do NOT set a global Content-Type for all requests; set it per request only when there is a body.
        // configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public API

    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        do {
            return try await performRequest(resource)
        } catch let error as NetworkError {
            // Attempt refresh ONCE when unauthorized, then retry
            if case .unauthorized = error {
                do {
                    try await refreshToken()
                    return try await performRequest(resource)
                } catch {
                    throw NetworkError.unauthorized(message: "Your session has expired. Please sign in again.")
                }
            }
            throw error
        } catch {
            // Map transport/decoding/etc.
            throw mapTransport(error)
        }
    }

    // MARK: - Core request

    private func performRequest<T: Codable>(_ resource: Resource<T>) async throws -> T {
        var request = URLRequest(url: resource.url)

        // HTTP method + query/body
        switch resource.method {
        case .get(let queryItems):
            if let items = queryItems, !items.isEmpty {
                var comps = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
                comps?.queryItems = items
                guard let url = comps?.url else {
                    throw NetworkError.badRequest(message: "Invalid query parameters.")
                }
                request.url = url
            } else {
                request.url = resource.url // no dangling "?"
            }
            request.httpMethod = "GET"

        case .delete:
            request.httpMethod = "DELETE"

        case .post(let data):
            request.httpMethod = "POST"
            request.httpBody = data

        case .put(let data):
            request.httpMethod = "PUT"
            request.httpBody = data
        }

        // Default headers (caller can override below)
        if request.httpBody != nil && request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        // Authorization header (sanitize token)
        if let raw = tokenStore.loadTokens().accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !raw.isEmpty
        {
            let token = raw.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Custom per-request headers (override defaults if needed)
        if let headers = resource.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // DEBUG: print cURL once you suspect issues
        #if DEBUG
        print("➡️ REQUEST:\n\(requestAsCurl(request))\n")
        #endif

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            switch http.statusCode {
            case 200..<300:
                do {
                    return try JSONDecoder().decode(resource.modelType, from: data)
                } catch {
                    throw NetworkError.decodingError(error)
                }

            default:
                // Parse API error payload → map to NetworkError
                throw parseAPIError(from: data, response: http)
            }

        } catch {
            // URLSession-level errors (no HTTP response)
            throw mapTransport(error)
        }
    }

    // MARK: - Token refresh

    func refreshToken() async throws {
        let refreshToken = tokenStore.loadTokens().refreshToken
        let body = try JSONEncoder().encode(["refreshToken": refreshToken])

        let resource = Resource(
            url: Constants.Urls.refresh,
            method: .post(body),
            headers: ["Accept": "application/json", "Content-Type": "application/json"],
            modelType: RefreshResponse.self
        )

        let response = try await performRequest(resource)
        tokenStore.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
    }

    // MARK: - Error mapping

    /// Try to decode the server's error payload and map to a specific NetworkError.
    private func parseAPIError(from data: Data, response: HTTPURLResponse) -> NetworkError {
        let payload = try? JSONDecoder().decode(ErrorResponse.self, from: data)
        let msg = payload?.message ?? payload?.error

        switch response.statusCode {
        case 400:
            return .badRequest(message: msg)

        case 401:
            return .unauthorized(message: msg)

        case 403:
            return .forbidden(message: msg)

        case 404:
            // Special-case user-not-found if the message hints so
            if let m = msg?.lowercased(), m.contains("user") {
                return .userNotFound(message: msg ?? "User not found.")
            }
            return .notFound(message: msg)

        case 409:
            return .conflict(message: msg)

        case 422:
            return .unprocessable(message: msg)

        case 429:
            let retryAfter: TimeInterval? = {
                if let v = response.value(forHTTPHeaderField: "Retry-After"),
                   let s = TimeInterval(v) { return s }
                return nil
            }()
            return .rateLimited(retryAfter: retryAfter, message: msg)

        case 500...599:
            return .server(status: response.statusCode, message: msg)

        default:
            return .undefined(data, response)
        }
    }

    /// Map URLSession/transport errors to NetworkError for consistent handling.
    private func mapTransport(_ error: Error) -> NetworkError {
        let ns = error as NSError
        guard ns.domain == NSURLErrorDomain else {
            // Often decoding, etc.
            if (error is DecodingError) {
                return .decodingError(error)
            }
            return .transport(error)
        }
        switch ns.code {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorCancelled:
            return .cancelled
        default:
            return .transport(error)
        }
    }

    // MARK: - Debug helpers

    private func requestAsCurl(_ request: URLRequest) -> String {
        var parts = ["curl -i"]
        if let method = request.httpMethod, method != "GET" { parts += ["-X", method] }
        request.allHTTPHeaderFields?.forEach { k, v in parts += ["-H", "'\(k): \(v)'"] }
        if let body = request.httpBody, !body.isEmpty,
           let s = String(data: body, encoding: .utf8) {
            parts += ["--data-raw", "'\(s.replacingOccurrences(of: "'", with: "\\'"))'"]
        }
        if let u = request.url?.absoluteString { parts.append("'\(u)'") }
        return parts.joined(separator: " ")
    }
}



//import Foundation
//import Security
//
//enum HTTPMethod {
//    case get([URLQueryItem]?)   // ← allow nil to distinguish “no query”
//    case post(Data?)
//    case put(Data?)
//    case delete
//
//    var name: String {
//        switch self {
//        case .get: return "GET"
//        case .post: return "POST"
//        case .put: return "PUT"
//        case .delete: return "DELETE"
//        }
//    }
//}
//
//struct Resource<T: Codable> {
//    let url: URL
//    var method: HTTPMethod = .get([])
//    var headers: [String: String]? = nil
//    var modelType: T.Type
//}
//
//struct HTTPClient {
//    
//    private let session: URLSession
//    private let tokenStore = TokenStore()
//    
//    init() {
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
//        self.session = URLSession(configuration: configuration)
//    }
//    
//    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
//        do {
//            return try await performRequest(resource)
//        } catch NetworkError.unauthorized {
//            // Attempt to refresh the token
//            do {
//                try await refreshToken()
//                return try await performRequest(resource)
//            } catch {
//                throw NetworkError.unauthorized
//            }
//        }
//    }
//    
//    private func performRequest<T: Codable>(_ resource: Resource<T>) async throws -> T {
//        var request = URLRequest(url: resource.url)
//
//        switch resource.method {
//        case .get(let queryItems):
//            if let items = queryItems, !items.isEmpty {
//                var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
//                components?.queryItems = items
//                guard let url = components?.url else {
//                    throw NetworkError.badRequest
//                }
//                request.url = url
//            } else {
//                // No query → ensure we DO NOT end with a dangling "?"
//                request.url = resource.url
//            }
//
//        case .delete:
//            request.httpMethod = resource.method.name
//
//        case .post(let data):
//            request.httpMethod = resource.method.name
//            request.httpBody = data
//
//        case .put(let data):
//            request.httpMethod = resource.method.name
//            request.httpBody = data
//        }
//
//        // Default headers (add these before custom headers so callers can override)
//        if request.httpBody != nil && request.value(forHTTPHeaderField: "Content-Type") == nil {
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        }
//        if request.value(forHTTPHeaderField: "Accept") == nil {
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
//        }
//
//        // Authorization header
//        if let accessToken = tokenStore.loadTokens().accessToken, !accessToken.isEmpty {
//            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        }
//
//        // Custom per-request headers (can override defaults)
//        if let headers = resource.headers {
//            for (key, value) in headers {
//                request.setValue(value, forHTTPHeaderField: key)
//            }
//        }
//
//        let (data, response) = try await session.data(for: request)
//        
//        
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//
//        switch httpResponse.statusCode {
//        case 200..<300:
//            break
//        case 400:
//            throw NetworkError.badRequest
//        case 401:
//            throw NetworkError.unauthorized
//        case 404:
//            throw NetworkError.notFound
//        default:
//            throw NetworkError.undefined(data, httpResponse)
//        }
//
//        do {
//            // Decode as the requested model type
//            return try JSONDecoder().decode(resource.modelType, from: data)
//            // or: return try JSONDecoder().decode(T.self, from: data)
//        } catch {
//            // Don't force-cast a String to Error; bubble the real decoding error
//            throw NetworkError.decodingError(error)
//        }
//    }
//
//    
//    func refreshToken() async throws {
//        let refreshToken =  tokenStore.loadTokens().refreshToken
//        
//        let body = try JSONEncoder().encode(["refreshToken": refreshToken])
//        let resource = Resource(url: Constants.Urls.refresh, method: .post(body), modelType: RefreshResponse.self)
//        
//        let response = try await performRequest(resource)
//
//        tokenStore.saveTokens(accessToken: response.accessToken, refreshToken: response.refreshToken)
//    }
//}
//
