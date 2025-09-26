//
//  MockData.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/26/25.
//
import SwiftUI

@MainActor
@Observable
class MockPlatziStore: PlatziStore {
    init(filename: String = "MockCategories") {
        super.init(httpClient: HTTPClient()) // Not really used for preview
        self.categories = Self.loadJSON(filename)
    }
    
    private static func loadJSON(_ filename: String) -> [Category] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ Could not find \(filename).json in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Category].self, from: data)
        } catch {
            print("⚠️ Error decoding \(filename).json: \(error)")
            return []
        }
    }
}
