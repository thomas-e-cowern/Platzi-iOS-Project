//
//  ProductListScreen.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/9/25.
//

import SwiftUI

struct ProductListScreen: View {
    
    @Environment(PlatziStore.self) private var platziStore
    @State private var products: [Product] = []
    
    var body: some View {
        List(products) { product in
            Text(product.title)
        }
        .task {
            do {
                products = try await platziStore.loadProductsByCategoryId(3)
            } catch {
                print("Error getting products in getAllProductsByCategory: \(error.localizedDescription)")
            }
        }
    }
    
    func getAllProductsByCategory(_ categoryId: Int = 1) async throws {
        do {
            products = try await platziStore.loadProductsByCategoryId(categoryId)
        } catch {
            print("Error getting products in getAllProductsByCategory: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        ProductListScreen()
            .environment(PlatziStore(httpClient: HTTPClient()))
    }
}
