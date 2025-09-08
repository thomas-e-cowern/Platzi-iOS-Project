//
//  PlatziStore.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/6/25.
//

import Foundation
import Observation

@MainActor
@Observable
class PlatziStore {
    let httpClient: HTTPClient
    
    var categories: [Category] = []
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func loadCategories() async throws {
        let resource = Resource(url: Constants.Urls.categories, modelType: [Category].self)
        categories = try await httpClient.load(resource)
    }
    
    func addCategory(name: String, imageUrl: String) async throws {
        let addCategoryRequest = AddCategory(name: name, image: imageUrl)
        let resource = Resource(url: Constants.Urls.addCategory, method: .post(try addCategoryRequest.encode()), modelType: Category.self)
        let newCategory = try await httpClient.load(resource)
        print("New Category added: \(newCategory)")
        categories.append(newCategory)
    }
    
}
