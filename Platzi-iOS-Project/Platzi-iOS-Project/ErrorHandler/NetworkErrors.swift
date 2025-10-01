//
//  NetworkErrors.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/1/25.
//

import Foundation

enum NetworkError: Error {
    case badRequest(message: String? = nil)                  // 400
    case unauthorized(message: String? = nil)                // 401
    case forbidden(message: String? = nil)                   // 403
    case notFound(message: String? = nil)                    // 404 (generic)
    case userNotFound(message: String? = nil)                // 404 (specific, when we know it's a user)
    case conflict(message: String? = nil)                    // 409
    case unprocessable(message: String? = nil)               // 422
    case rateLimited(retryAfter: TimeInterval? = nil,
                     message: String? = nil)                 // 429
    case server(status: Int, message: String? = nil)         // 5xx
    case decodingError(Error)
    case invalidResponse
    case timeout                                            // URLSession timeout
    case cancelled                                          // URLSession cancelled
    case transport(Error)                                   // Other URLSession errors
    case undefined(Data, HTTPURLResponse)                   // Fallback with raw payload
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badRequest(let msg):
            return msg ?? NSLocalizedString("Bad Request (400): Unable to perform the request.", comment: "badRequestError")

        case .unauthorized(let msg):
            return msg ?? NSLocalizedString("Unauthorized: Please sign in again.", comment: "authorizationError")

        case .forbidden(let msg):
            return msg ?? NSLocalizedString("Forbidden: You don’t have permission to do that.", comment: "forbiddenError")

        case .notFound(let msg):
            return msg ?? NSLocalizedString("Resource not found (404).", comment: "notFoundError")

        case .userNotFound(let msg):
            return msg ?? NSLocalizedString("User not found.", comment: "userNotFoundError")

        case .conflict(let msg):
            return msg ?? NSLocalizedString("Conflict: The request conflicts with the current state.", comment: "conflictError")

        case .unprocessable(let msg):
            return msg ?? NSLocalizedString("Unprocessable: The data you sent is invalid.", comment: "unprocessableError")

        case .rateLimited(_, let msg):
            return msg ?? NSLocalizedString("Too many requests: Please try again in a moment.", comment: "rateLimitedError")

        case .server(let status, let msg):
            return msg ?? String(format: NSLocalizedString("Server error (%d). Please try again later.", comment: "serverError"), status)

        case .decodingError(let error):
            return NSLocalizedString("Unable to decode the server response. \(error)", comment: "decodingError")

        case .invalidResponse:
            return NSLocalizedString("Invalid response.", comment: "invalidResponse")

        case .timeout:
            return NSLocalizedString("The request timed out. Check your connection and try again.", comment: "timeoutError")

        case .cancelled:
            return NSLocalizedString("The request was cancelled.", comment: "cancelledError")

        case .transport(let error):
            return NSLocalizedString("A network error occurred. \(error.localizedDescription)", comment: "transportError")

        case .undefined(let data, let response):
            if let decoded = try? JSONDecoder().decode(ErrorResponse.self, from: data),
               let message = decoded.message ?? decoded.error {
                return message
            } else {
                return "An unexpected error occurred. Status code: \(response.statusCode)"
            }
        }
    }
}

private func parseAPIError(from data: Data, response: HTTPURLResponse) -> NetworkError {
    // Try to pull a message from the server payload
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
        // Heuristic: if server message mentions "user", raise the specific error.
        if let m = msg?.lowercased(), m.contains("user") {
            return .userNotFound(message: msg)
        }
        return .notFound(message: msg)
    case 409:
        return .conflict(message: msg)
    case 422:
        return .unprocessable(message: msg)
    case 429:
        // Try to parse Retry-After header (seconds)
        let retryAfterSeconds: TimeInterval? = {
            if let v = response.value(forHTTPHeaderField: "Retry-After"),
               let s = TimeInterval(v) { return s }
            return nil
        }()
        return .rateLimited(retryAfter: retryAfterSeconds, message: msg)
    case 500...599:
        return .server(status: response.statusCode, message: msg)
    default:
        return .undefined(data, response)
    }
}


