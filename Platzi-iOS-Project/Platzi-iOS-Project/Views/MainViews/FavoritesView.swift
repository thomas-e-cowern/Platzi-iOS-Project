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
            if productsArray.isEmpty && !isLoading {
                ContentUnavailableView("No Products Available", systemImage: "shippingbox")
            } else if isLoading {
                ProgressView("Loading Favorites…")
            } else {
                List {
                    ForEach(productsArray, id: \.id) { product in
                        if product.title == "Product unavailable" {
                            NavigationLink {
                                UnavailableProductView(
                                    productId: product.id,
                                    onRemove: { removeFavorite(product.id) }
                                )
                            } label: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Product no longer available")
                                            .font(.headline)
                                            .foregroundStyle(.red)
                                        Text("This item has been removed or is no longer sold.")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Product no longer available. Double-tap for details.")
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    removeFavorite(product.id)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
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
        .task {
            await fetchFavorites()
        }
    }

    // MARK: - Fetch favorites

    private func fetchFavorites() async {
        await MainActor.run { isLoading = true }

        let results = await loadProductsByIdsLenient(Array(favorites.favoriteIDs))

        let loaded: [Product] = results.enumerated().map { (index, result) in
            switch result {
            case .success(let product):
                // Return real product or placeholder if nil
                return product ?? unavailablePlaceholder(for: Array(favorites.favoriteIDs)[index])
            case .failure:
                // Return placeholder for any error
                return unavailablePlaceholder(for: Array(favorites.favoriteIDs)[index])
            }
        }

        await MainActor.run {
            self.products = loaded
            self.isLoading = false
        }
    }
    
    
    // MARK: - Remove Favorite
    
    private func removeFavorite(_ id: Int) {
        // If your Favorites type exposes a method:
        favorites.remove(id)

        // If it only exposes the Set, use this instead:
        // favorites.favoriteIDs.remove(id)

        withAnimation {
            products.removeAll { $0.id == id }
        }
    }


    // MARK: - Placeholder factory

    private func unavailablePlaceholder(for id: Int) -> Product {
        Product(
            id: id,
            title: "Product unavailable",
            slug: "product-unavailable",
            price: 0,
            description: "This product is no longer available.",
            category: Category(id: 0, name: "Unavailable", slug: "", image: ""),
            images: []
        )
    }

    // MARK: - Batch loader

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
                            return (i, .success(nil)) // mark unavailable
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
