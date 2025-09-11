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
    @State private var showAddProductScreen: Bool = false
    
    var body: some View {
        ZStack {
            if products.isEmpty && !isLoading {
                ContentUnavailableView("No Products Available", systemImage: "shippingbox")
            } else {
                List(products) { product in
                    HStack(spacing: 15) {
                        if let image = product.images.first {
                            NavigationLink {
                                ProductDetailView(product: product)
                            } label: {
                                RowView(title: product.title, imageUrl: image)
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView("Loading...")
            }
        }
        .task {
            await getAllProductsByCategory(category.id)
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddProductScreen.toggle()
                } label: {
                    Text("Add New Product")
                }

            }
        }
        .sheet(isPresented: $showAddProductScreen) {
            NavigationStack {
                AddProductScreen(categoryId: category.id) { product in
                    print("New product: \(product)")
                    products.append(product)
                }
            }
        }
    }
    
    func getAllProductsByCategory(_ categoryId: Int) async {
        
        defer {
            isLoading = false
        }
        
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
        ProductListScreen(category: Category(id: 1, name: "Rocks", slug: "rocks", image: "https://picsum.photos/200"))
            .environment(PlatziStore(httpClient: HTTPClient()))
    }
}
