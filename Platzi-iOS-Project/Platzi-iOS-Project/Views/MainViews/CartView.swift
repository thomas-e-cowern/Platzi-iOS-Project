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
                    showCheckoutView.toggle()
                } label: {
                    Text("Complete Checkout")
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("Shopping Cart")
            .sheet(isPresented: $showCheckoutView) {
                VStack {
                    ZStack {
                        Circle()
                            .frame(width: 40)
                            .foregroundStyle(.gray)
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.green)
                    }
                    .padding(.bottom, 10)
                    
                    Text("Congratulations! You have successfully completed your checkout!")
                        .font(.largeTitle)
                    
                    Spacer()
                        .frame(height: 50)
                    
                    Text("If this had been a real app, you would receive an email with a link to download your receipt.")
                        .font(.title)
                        .padding()
                }
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
