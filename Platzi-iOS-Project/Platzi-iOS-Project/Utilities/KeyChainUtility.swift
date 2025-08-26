//
//  KeyChainUtility.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/26/25.
//

import Foundation
import Security

struct TokenStore {
    private let service = "com.yourapp.tokens"
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    
    // Save tokens
    func saveTokens(accessToken: String, refreshToken: String) {
        save(key: accessTokenKey, data: accessToken)
        save(key: refreshTokenKey, data: refreshToken)
    }
    
    // Retrieve tokens
    func loadTokens() -> (accessToken: String?, refreshToken: String?) {
        let accessToken = load(key: accessTokenKey)
        let refreshToken = load(key: refreshTokenKey)
        return (accessToken, refreshToken)
    }
    
    // Delete tokens
    func clearTokens() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }
    
    // MARK: - Keychain Helpers
    
    private func save(key: String, data: String) {
        if let data = data.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String       : kSecClassGenericPassword,
                kSecAttrService as String : service,
                kSecAttrAccount as String : key,
                kSecValueData as String   : data
            ]
            
            // Delete existing first
            SecItemDelete(query as CFDictionary)
            
            // Add new
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    private func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

