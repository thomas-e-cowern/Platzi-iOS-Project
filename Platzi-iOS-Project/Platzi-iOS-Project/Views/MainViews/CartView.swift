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
        NavigationStack {
            VStack {
                List {
                    ForEach(cartStore.cartProducts) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text(item.price, format: .currency(code: "USD"))
                            Button(action: {
                                cartStore.removeProduct(item)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                Text("Total: \(cartStore.total, format: .currency(code: "USD"))")
                    .font(.title2)
                    .padding()
                Spacer()
            }
            .navigationTitle("Shopping Cart")
        }
    }
}

#Preview {
    NavigationStack {
        CartView()
            .environment(CartStore())
    }
}
