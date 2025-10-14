//
//  FavoritesView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/13/25.
//

import SwiftUI

struct FavoritesView: View {

    @Environment(CartStore.self) private var cartStore
    @Environment(PlatziStore.self) private var platziStore
    @Environment(Favorites.self) private var favorites

    @State private var showAddProductScreen = false
    @State private var isLoading = false
    @State private var products: [Product] = []

    // Stable order
    private var productsArray: [Product] {
        products.sorted { $0.id < $1.id }
    }

    var body: some View {
        ZStack {
            if productsArray.isEmpty {
                ContentUnavailableView("No Products Available", systemImage: "shippingbox")
            } else {
                List {
                    ForEach(productsArray, id: \.id) { product in
                        if product.title == "Product unavailable" {
                            Text("Product no longer available")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else {
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
                .navigationTitle("Favorites")
            }
        }
        .task {   // preferred over onAppear for one-shot loads
            isLoading = true
            let results = await loadProductsByIdsLenient(Array(favorites.favoriteIDs))

            // Convert [Result<Product?, Error>] -> [Product]
            let loaded: [Product] = results.compactMap { res in
                switch res {
                case .success(let product): return product       // may be the “unavailable” placeholder
                case .failure: return nil                        // drop hard failures, or make another placeholder
                }
            }

            await MainActor.run {
                self.products = loaded
                self.isLoading = false
            }
        }
    }

    /// Returns results aligned to `ids` (same count, same order).
    func loadProductsByIdsLenient(_ ids: [Int]) async -> [Result<Product?, Error>] {
        await withTaskGroup(of: (Int, Result<Product?, Error>).self) { group in
            for (i, id) in ids.enumerated() {
                group.addTask {
                    do {
                        let product = try await platziStore.loadOneProductById(id)
                        return (i, .success(product))
                    } catch let error as NetworkError {
                        switch error {
                        case .badRequest:
                            // Product no longer available → return placeholder
                            let unavailable = Product(
                                id: id,
                                title: "Product unavailable",
                                slug: "product-unavailable",
                                price: 0,
                                description: "This product is no longer available.",
                                category: Category(id: 0, name: "Unavailable", slug: "", image: ""),
                                images: []
                            )
                            return (i, .success(unavailable))
                        default:
                            return (i, .failure(error))
                        }
                    } catch {
                        return (i, .failure(error))
                    }
                }
            }

            var tmp: [(Int, Result<Product?, Error>)] = []
            tmp.reserveCapacity(ids.count)
            for await pair in group { tmp.append(pair) }
            return tmp.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
}


#Preview {
    FavoritesView()
        .environment(PlatziStore(httpClient: HTTPClient()))
        .environment(CartStore())
        .environment(Favorites())
}
