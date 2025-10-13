//
//  CartStore.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/22/25.
//

import Foundation
import SwiftUI

@Observable
class CartStore {
    
    init() { print("CartStore init") }
    deinit { print("CartStore deinit") }
    
    
    var cartProducts: [Product] = []
    var favorites: [Product] = []
    
    var total: Int {
        cartProducts.reduce(0) { $0 + ($1.price * $1.quantityOrdered) }
    }
    
    // Add to cart; if already present, bump quantity
    func add(_ product: Product, quantity: Int = 1) {
        if let idx = cartProducts.firstIndex(where: { $0.id == product.id }) {
            cartProducts[idx].quantityOrdered += quantity
        } else {
            var p = product
            p.quantityOrdered = max(1, quantity)
            cartProducts.append(p)
        }
    }
    
    func increment(_ product: Product) {
        guard let idx = cartProducts.firstIndex(where: { $0.id == product.id }) else { return }
        cartProducts[idx].quantityOrdered += 1
    }
    
    func decrement(_ product: Product) {
        guard let idx = cartProducts.firstIndex(where: { $0.id == product.id }) else { return }
        if cartProducts[idx].quantityOrdered > 1 {
            cartProducts[idx].quantityOrdered -= 1
        } else {
            // at 1 → remove when decrementing
            cartProducts.remove(at: idx)
        }
    }
    
    func removeProduct(_ product: Product) {
        cartProducts.removeAll { $0.id == product.id }
    }
}


//@Observable
//class CartStore {
//    var cartProducts: [Product] = []
//
//    func addProduct(_ product: Product) {
//        cartProducts.append(product)
//        // You might want to handle quantity updates if the same product is added multiple times
//    }
//
//    func removeProduct(_ product: Product) {
//        if let index = cartProducts.firstIndex(of: product) {
//            cartProducts.remove(at: index)
//        }
//    }
//
//    var total: Int {
//        cartProducts.reduce(0) { $0 + $1.price }
//    }
//
//}

extension CartStore {
    static var preview: [Product] {
        [Product(id: 1, title: "Test Product", slug: "Test Product", price: 100, description: "This is a test product used in cart development", category: Category(id: 31, name: "Clothes", slug: "clothes", image: "https://i.imgur.com/QkIa5tT.jpeg"), images: [
            "https://i.imgur.com/1twoaDy.jpeg",
            "https://i.imgur.com/FDwQgLy.jpeg",
            "https://i.imgur.com/kg1ZhhH.jpeg"
        ])
        ]
    }
}
