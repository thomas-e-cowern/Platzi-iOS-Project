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
                    cartStore.addProduct(product)
                    print("Cart: \(cartStore.cartProducts)")
                    print("Total: \(cartStore.total)")
                } label: {
                    Text("Add to Cart")
                }
                .buttonStyle(.bordered)

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
