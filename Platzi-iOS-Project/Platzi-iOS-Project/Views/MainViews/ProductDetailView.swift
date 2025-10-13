//
//  ProductDetailView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/10/25.
//

import SwiftUI

struct ProductDetailView: View {
    
    @Environment(CartStore.self) private var cartStore
    
    var product: Product
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
                    isFavorite.toggle()
                    updateFavorites(id: product.id)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                }
                .padding(.top, 12)
                

            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func updateFavorites(id: Int) {
        if isFavorite == true {
            cartStore.favorites.append(product)
            print("Add to favorites...")
            print(cartStore.favorites)
            print(cartStore.favorites.count)
        } else {
            cartStore.favorites.removeAll { $0.id == id }
            print("removed from favorites...")
            print(cartStore.favorites)
            print(cartStore.favorites.count)
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.preview)
            .environment(CartStore())
    }
}
