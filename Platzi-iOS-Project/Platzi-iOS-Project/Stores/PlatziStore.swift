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
    var locations: [Location] = []
    
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
    
    func loadProductsByCategoryId(_ categoryId: Int) async throws -> [Product] {
        let resource = Resource(url: Constants.Urls.getProductsByCategory(categoryId), modelType: [Product].self)
        return try await httpClient.load(resource)
    }
    
    func loadOneProductById(_ productId: Int) async throws -> Product {
        let getProductRequest = GetProductById(productId: productId)
        let resource = Resource(url: Constants.Urls.getProductById(productId), modelType: Product.self)
        return try await httpClient.load(resource)
    }
    
    func addProduct(title: String, price: Int, description: String, categoryId: Int, images: [String]) async throws -> Product {
        let addProductRequest = AddProduct(title: title, price: price, description: description, categoryId: categoryId, images: images)
        let resource = Resource(url: Constants.Urls.addProduct, method: .post(try addProductRequest.encode()), modelType: Product.self)
        let newProduct = try await httpClient.load(resource)
        return newProduct
    }
    
    func deleteProductById(_ productId: Int) async throws -> Bool {
        let resource = Resource(url: Constants.Urls.deleteProductById(productId), method: .delete, modelType: Bool.self)
        let deletedProductSuccess = try await httpClient.load(resource)
        print("Deleted Product: \(deletedProductSuccess)")
        return deletedProductSuccess
    }
    
    func loadLocations() async throws -> [Location] {
        let resource = Resource(url: Constants.Urls.locations, modelType: [Location].self)
        locations = try await httpClient.load(resource)
        return locations
    }
}
