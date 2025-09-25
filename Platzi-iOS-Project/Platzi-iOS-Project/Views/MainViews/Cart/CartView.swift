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

    var isCheckoutDisabled: Bool { cartStore.total == 0 }

    var body: some View {
        NavigationStack {
            ZStack {
                if cartStore.cartProducts.isEmpty {
                    ContentUnavailableView("You have nothing in your cart", systemImage: "shippingbox")
                } else {
                    VStack {
                        List {
                            ForEach(cartStore.cartProducts) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(item.title).font(.headline)
                                        Spacer()
                                        Text((item.price * item.quantityOrdered), format: .currency(code: "USD"))
                                    }

                                    HStack(spacing: 12) {
                                        Button { cartStore.decrement(item) } label: {
                                            Image(systemName: "minus.circle.fill").imageScale(.large)
                                        }
                                        .buttonStyle(.plain) // tap area is icon only

                                        Text("\(item.quantityOrdered)")
                                            .monospacedDigit()
                                            .frame(minWidth: 28)

                                        Button { cartStore.increment(item) } label: {
                                            Image(systemName: "plus.circle.fill").imageScale(.large)
                                        }
                                        .buttonStyle(.plain)

                                        Spacer()

                                        Text(item.price, format: .currency(code: "USD"))
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .contentShape(Rectangle()) // define row hit area (not the delete)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        cartStore.removeProduct(item)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
 // MARK: - End of list

                        Text("Total: \(cartStore.total, format: .currency(code: "USD"))")
                            .font(.title2.weight(.semibold))
                            .padding(.top, 8)

                        Button("Complete Checkout") {
                            showCartInfoView.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isCheckoutDisabled)
                        .padding(.vertical)

                    }
                    .navigationTitle("Shopping Cart")
                    .sheet(isPresented: $showCartInfoView) {
                        CartInfoView {
                            withAnimation { cartStore.cartProducts.removeAll() }
                            showCartInfoView = false
                        }
                        .padding()
                    }
                }
            }
        }
    }
}


//struct CartView: View {
//    @Environment(CartStore.self) private var cartStore
//    @State private var showCheckoutView: Bool = false
//    @State private var showCartInfoView: Bool = false
//    
//    var isCheckoutDisabled: Bool {
//        if cartStore.total == 0 {
//            return true
//        }
//        return false
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                if cartStore.cartProducts.isEmpty {
//                    ContentUnavailableView("You have nothing in your cart", systemImage: "shippingbox")
//                } else {
//                    VStack {
//                        List {
//                            ForEach(cartStore.cartProducts) { item in
//                                HStack {
//                                    Text(item.title)
//                                    Spacer()
//                                    Text(item.price, format: .currency(code: "USD"))
//                                    Button(action: {
//                                        cartStore.removeProduct(item)
//                                    }) {
//                                        Image(systemName: "minus.circle.fill")
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                            }
//                        }
//                        Text("Total: \(cartStore.total, format: .currency(code: "USD"))")
//                            .font(.title2)
//                            .padding()
//                        Spacer()
//                        Button {
//                            showCartInfoView.toggle()
//                        } label: {
//                            Text("Complete Checkout")
//                        }
//                        .buttonStyle(.bordered)
//                        .disabled(isCheckoutDisabled)
//                    }
//                    .navigationTitle("Shopping Cart")
//                    .sheet(isPresented: $showCartInfoView, onDismiss: {
//                        cartStore.cartProducts = []
//                    }) {
//                        CartInfoView()
//                            .padding()
//                    }
//                }
//            }
//            
//        }
//    }
//}

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
