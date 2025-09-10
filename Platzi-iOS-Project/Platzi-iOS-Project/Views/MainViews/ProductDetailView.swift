//
//  ProductDetailView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/10/25.
//

import SwiftUI

struct ProductDetailView: View {
    
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
            }
            .padding()
        }
        .navigationTitle(product.title)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.preview)
    }
}
