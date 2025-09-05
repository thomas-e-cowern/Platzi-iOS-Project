//
//  JWTDecoder.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/5/25.
//

import Foundation

/// Minimal claims we care about. Add more fields as needed.
struct JWTClaims: Decodable {
    let exp: TimeInterval?   // seconds since epoch
    let iat: TimeInterval?
    let nbf: TimeInterval?
}

enum JWTError: Error, LocalizedError {
    case invalidFormat
    case badBase64
    case badJSON
    case missingPayload
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat: return "Token must have 3 dot-separated parts."
        case .badBase64:     return "Token payload is not valid Base64URL."
        case .badJSON:       return "Token payload JSON could not be decoded."
        case .missingPayload:return "Token payload part is missing."
        }
    }
}

struct JWT {
    /// Decode the payload into strongly-typed claims (no signature verification).
    static func decodeClaims(from token: String) throws -> JWTClaims {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { throw JWTError.invalidFormat }
        guard let payloadPart = parts.dropFirst().first else { throw JWTError.missingPayload }
        
        guard let data = base64urlDecode(String(payloadPart)) else { throw JWTError.badBase64 }
        do {
            return try JSONDecoder().decode(JWTClaims.self, from: data)
        } catch {
            throw JWTError.badJSON
        }
    }
    
    /// Returns the token's expiration date if present.
    static func expirationDate(from token: String) throws -> Date? {
        let claims = try decodeClaims(from: token)
        if let exp = claims.exp { return Date(timeIntervalSince1970: exp) }
        return nil
    }
    
    /// Checks whether the token is expired, with optional leeway (seconds) to tolerate clock skew.
    static func isExpired(_ token: String, leeway seconds: TimeInterval = 0) -> Bool {
        do {
            guard let exp = try expirationDate(from: token) else {
                // If no `exp` claim, treat as expired for safety.
                return true
            }
            return Date().addingTimeInterval(seconds) >= exp
        } catch {
            // If decoding fails, be conservative.
            return true
        }
    }
    
    /// Seconds remaining until expiration (negative if already expired). Returns nil if no `exp`.
    static func secondsUntilExpiry(_ token: String) -> TimeInterval? {
        do {
            guard let exp = try expirationDate(from: token) else { return nil }
            return exp.timeIntervalSinceNow
        } catch {
            return nil
        }
    }
    
    // MARK: - Helpers
    
    /// Base64URL → Data (RFC 7515/7519)
    private static func base64urlDecode(_ base64url: String) -> Data? {
        var string = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        // pad to multiple of 4
        let padding = 4 - (string.count % 4)
        if padding < 4 { string.append(String(repeating: "=", count: padding)) }
        return Data(base64Encoded: string)
    }
}

