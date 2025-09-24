//
//  CartView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/22/25.
//

import SwiftUI

struct CartView: View {
    @Environment(CartStore.self) private var cartStore
    @State private var showCheckoutView: Bool = false
    @State private var showCartInfoView: Bool = false
    @State private var itemAmount: Int = 1
    
    var isCheckoutDisabled: Bool {
        if cartStore.total == 0 {
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if cartStore.cartProducts.isEmpty {
                    ContentUnavailableView("You have nothing in your cart", systemImage: "shippingbox")
                } else {
                    VStack {
                        List {
                            ForEach(cartStore.cartProducts) { item in
                                VStack {
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
                                    HStack {
                                        
                                    }
                                }
                            }
                        }
                        Text("Total: \(cartStore.total, format: .currency(code: "USD"))")
                            .font(.title2)
                            .padding()
                        Spacer()
                        Button {
                            showCartInfoView.toggle()
                        } label: {
                            Text("Complete Checkout")
                        }
                        .buttonStyle(.bordered)
                        .disabled(isCheckoutDisabled)
                    }
                    .navigationTitle("Shopping Cart")
                    .sheet(isPresented: $showCartInfoView, onDismiss: {
                        cartStore.cartProducts = []
                    }) {
                        CartInfoView()
                            .padding()
                    }
                }
            }
            
        }
    }
}

#Preview("Empty Cart") {
    NavigationStack {
        CartView()
            .environment(CartStore())
    }
}

#Preview("Item in Cart") {
    let store: CartStore = {
        let s = CartStore()
        s.cartProducts = [
            Product(id: 1, title: "Test Product", slug: "Test Product", price: 100, description: "This is a test product used in cart development", category: Category(id: 31, name: "Clothes", slug: "clothes", image: "https://i.imgur.com/QkIa5tT.jpeg"), images: [
                "https://i.imgur.com/1twoaDy.jpeg",
                "https://i.imgur.com/FDwQgLy.jpeg",
                "https://i.imgur.com/kg1ZhhH.jpeg"
                ])
        ]
        return s
    }()
    
    NavigationStack {
        CartView()
            .environment(store)
    }
}
