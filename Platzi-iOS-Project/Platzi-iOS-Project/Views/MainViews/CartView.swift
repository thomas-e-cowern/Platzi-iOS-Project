//
//  CartView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/22/25.
//

import SwiftUI

struct CartView: View {
    @Environment(CartStore.self) private var cartStore

    var body: some View {
        VStack {
            List {
                ForEach(cartStore.cartProducts) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text(String(format: "$%.2f", item.price))
                        Button(action: {
                            cartStore.removeProduct(item)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            Text("Total: \(String(format: "$%.2f", cartStore.total))")
                .font(.title2)
                .padding()
            Spacer()
        }
        .navigationTitle("Shopping Cart")
    }
}

#Preview {
    CartView()
        .environment(CartStore())
}
