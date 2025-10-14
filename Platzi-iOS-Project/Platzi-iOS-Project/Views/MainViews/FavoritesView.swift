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
    
    @State private var showAddProductScreen: Bool = false
    @State private var isLoading: Bool = false
    @State private var products: [Product] = []
    
    var body: some View {
        ZStack {
            if favorites.favoriteIDs.isEmpty {
                ContentUnavailableView("No Products Available", systemImage: "shippingbox")
            } else {
                List {
                    ForEach(Array(favorites.favoriteIDs), id: \.self) { favorite in
                        Text("\(favorite)")
                    }
                }
                .navigationTitle("Favorites")
            }
        }
        .onAppear {
            Task {
                // Collect successes + errors per-ID
                let products = await loadProductsByIdsLenient(Array(favorites.favoriteIDs))
                for (i, r) in products.enumerated() {
                    switch r {
                    case .success(let p): print("OK \(i): \(p.id)")
                    case .failure(let e): print("Failed \(i): \(e)")
                    }
                }
            }
        }
    }
    
    /// Returns results aligned to `ids` (same count, same order).
    func loadProductsByIdsLenient(_ ids: [Int]) async -> [Result<Product, Error>] {
        await withTaskGroup(of: (Int, Result<Product, Error>).self) { group in
            for (i, id) in ids.enumerated() {
                group.addTask {
                    do { return (i, .success(try await platziStore.loadOneProductById(id))) }
                    catch { return (i, .failure(error)) }
                }
            }

            var tmp: [(Int, Result<Product, Error>)] = []
            tmp.reserveCapacity(ids.count)

            for await pair in group { tmp.append(pair) }
            return tmp.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }

}

#Preview {
    FavoritesView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
