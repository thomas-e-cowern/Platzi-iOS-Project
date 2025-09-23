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
    
    var isCheckoutDisabled: Bool {
        if cartStore.total == 0 {
            return true
        }
        return false
    }
    
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
                Button {
                    showCartInfoView.toggle()
                } label: {
                    Text("Complete Checkout")
                }
                .buttonStyle(.bordered)
                .disabled(isCheckoutDisabled)
            }
            .navigationTitle("Shopping Cart")
            .sheet(isPresented: $showCartInfoView) {
                CartInfoView()
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CartView()
            .environment(CartStore())
    }
}
