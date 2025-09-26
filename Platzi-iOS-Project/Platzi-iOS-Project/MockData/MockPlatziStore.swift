//
//  MockData.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/26/25.
//
import SwiftUI
import Observation

@MainActor
@Observable
class MockPlatziStore: PlatziStore {
    private let filename: String
    private let bundle: Bundle

    init(filename: String = "Categories", bundle: Bundle = .main) {
        self.filename = filename
        self.bundle = bundle
        super.init(httpClient: HTTPClient()) // not used in mock
        // Pre-seed so the preview shows immediately
        self.categories = JSONLoader.decode(filename, in: bundle) as [Category]
    }

    override func loadCategories() async throws {
        // Simulate a very short async load (optional)
        try? await Task.sleep(nanoseconds: 150_000_000)
        self.categories = JSONLoader.decode(filename, in: bundle) as [Category]
    }
}

enum JSONLoader {
    static func decode<T: Decodable>(_ filename: String, ext: String = "json", in bundle: Bundle) -> T {
        guard let url = bundle.url(forResource: filename, withExtension: ext) else {
            assertionFailure("Missing \(filename).\(ext)")
            // Return an empty array/object safely for previews
            if T.self is [Any].Type { return (try! JSONDecoder().decode(T.self, from: Data("[]".utf8))) }
            fatalError("Provide a default for non-array types if needed.")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            assertionFailure("Decoding \(filename).json failed: \(error)")
            if T.self is [Any].Type { return (try! JSONDecoder().decode(T.self, from: Data("[]".utf8))) }
            fatalError("Provide a default for non-array types if needed.")
        }
    }
}
