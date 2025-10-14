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
    
    @State private var showAddProductScreen: Bool = false
    
    var body: some View {
        ZStack {
            if cartStore.favorites.isEmpty {
                ContentUnavailableView("No Products Available", systemImage: "shippingbox")
            } else {
                List {
                    ForEach(cartStore.favorites) { product in
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
                .navigationTitle("Favorites")
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
