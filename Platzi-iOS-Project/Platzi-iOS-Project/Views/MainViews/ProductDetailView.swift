//
//  ProductDetailView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/10/25.
//

import SwiftUI

struct ProductDetailView: View {
    
    @Environment(CartStore.self) private var cartStore
    @Environment(Favorites.self) private var favorites
    
    @State var product: Product
    @State private var isFavorite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                
                ProductDetailImageView(images: product.images)
                    .padding()
                
                HStack {
                    Text(product.title)
                        .font(.headline)
                    Text("\(product.price)")
                }
                .padding()
                
                Text(product.description)
                    .font(.body)
                
                Spacer()
                
                Button {
                    cartStore.add(product)
                    print("Cart: \(cartStore.cartProducts)")
                    print("Total: \(cartStore.total)")
                } label: {
                    Text("Add to Cart")
                }
                .buttonStyle(.bordered)
                
                Button {
                    if favorites.contains(product.id) {
                        favorites.remove(product.id)
                    } else {
                        favorites.add(product.id)
                    }
                } label: {
                    Image(systemName: favorites.contains(product.id) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.contains(product.id) ? .red : .gray)
                }
                .padding(.top, 12)
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.preview)
            .environment(CartStore())
    }
}
