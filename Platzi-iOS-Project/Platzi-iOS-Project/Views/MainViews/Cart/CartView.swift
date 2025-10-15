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

    var isCheckoutDisabled: Bool { cartStore.cartProducts.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                if cartStore.cartProducts.isEmpty {
                    ContentUnavailableView("You have nothing in your cart", systemImage: "shippingbox")
                } else {
                    VStack(spacing: 0) {

                        // MARK: - Items
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
                                        .buttonStyle(.plain)

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
                                .contentShape(Rectangle())
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        cartStore.removeProduct(item)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        } // end List

                        // MARK: - Totals & Discounts
                        VStack(spacing: 12) {
                            HStack {
                                Text("Subtotal")
                                Spacer()
                                Text(cartStore.total, format: .currency(code: "USD"))
                            }

                            // 4-char discount code entry (SAVE/DEAL/LUCK/GIFT)
                            DiscountEntryView()

                            // Summary panel: source (admin vs code), savings, final total + clear code
                            DiscountSummaryView()

                            Button("Complete Checkout") {
                                showCartInfoView.toggle()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isCheckoutDisabled)
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(.bar) // keeps it visually separated from the list
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

#Preview("Empty Cart") {
    NavigationStack {
        CartView()
            .environment(CartStore())
    }
}

#Preview("Item in Cart + Admin (auto 15%)") {
    let store: CartStore = {
        let s = CartStore()
        s.cartProducts = [
            Product(
                id: 1,
                title: "Test Product",
                slug: "test-product",
                price: 100,
                description: "This is a test product used in cart development",
                category: Category(id: 31, name: "Clothes", slug: "clothes", image: "https://i.imgur.com/QkIa5tT.jpeg"),
                images: [
                    "https://i.imgur.com/1twoaDy.jpeg",
                    "https://i.imgur.com/FDwQgLy.jpeg",
                    "https://i.imgur.com/kg1ZhhH.jpeg"
                ]
            )
        ]
        s.userRole = "admin"          // demonstrates automatic 15% employee discount
        return s
    }()
    NavigationStack {
        CartView()
            .environment(store)
    }
}

#Preview("Item in Cart + Code (10%)") {
    let store: CartStore = {
        let s = CartStore()
        s.cartProducts = [
            Product(
                id: 2,
                title: "Another Product",
                slug: "another-product",
                price: 250,
                description: "Another item for testing",
                category: Category(id: 10, name: "Tech", slug: "tech", image: ""),
                images: []
            )
        ]
        _ = s.applyDiscountCode("DEAL") // 10% via code; will be ignored if admin (15%) is active
        return s
    }()
    NavigationStack {
        CartView()
            .environment(store)
    }
}
