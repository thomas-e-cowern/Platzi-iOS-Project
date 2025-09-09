//
//  ProductListScreen.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/9/25.
//

import SwiftUI

struct ProductListScreen: View {
    
    let category: Category
    
    @Environment(PlatziStore.self) private var platziStore
    @State private var products: [Product] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            if products.isEmpty && !isLoading {
                ContentUnavailableView("No Products Available", systemImage: "shippingbox")
            } else {
                List(products) { product in
                    HStack(spacing: 15) {
                        if let image = product.images.first {
                            AsyncImage(url: URL(string: image)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ImagePlaceholderView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        } 

                        Text(product.title)
                    }
                }
            }
        }
        .task {
            await getAllProductsByCategory(category.id)
        }
        .navigationTitle(category.name)
    }
    
    func getAllProductsByCategory(_ categoryId: Int) async {
        do {
            isLoading = true
            products = try await platziStore.loadProductsByCategoryId(categoryId)
            
        } catch {
            print("Error getting products in getAllProductsByCategory: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        ProductListScreen(category: Category(id: 1, name: "Rocks", slug: "rocks", image:" https://picsum.photos/200"))
            .environment(PlatziStore(httpClient: HTTPClient()))
    }
}
