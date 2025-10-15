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
    
    // MARK: - Properties
    var cartProducts: [Product] = []
    var favorites: [Product] = []
    
    // MARK: - Discounts
    var userRole: String = "customer"          // or "admin"
    var appliedDiscountCode: String? = nil
    var activeDiscountPercent: Double = 0.0
    var discountCleared: Bool = false
    
    /// Predefined 4-character discount codes
    let discountCodes: [String: Double] = [
        "SAVE": 0.05,  // 5%
        "DEAL": 0.10,  // 10%
        "LUCK": 0.15,  // 15%
        "EMPL": 0.15,  // Employee 15% discount
        "GIFT": 0.20   // 20%
    ]
    
    // MARK: - Totals
    var total: Int {
        cartProducts.reduce(0) { $0 + ($1.price * $1.quantityOrdered) }
    }
    
    /// Final total after applying employee or code-based discount
    var finalTotal: Double {
        let baseTotal = Double(total)
        let discount = activeDiscountPercent
        
        // Apply automatic admin discount (15%) if applicable
        let employeeDiscount = (userRole == "admin") ? 0.15 : 0.0
        
        let totalDiscount = max(discount, employeeDiscount)
        return baseTotal * (1.0 - totalDiscount)
    }
    
    // MARK: - Cart Management
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
            cartProducts.remove(at: idx)
        }
    }
    
    func removeProduct(_ product: Product) {
        cartProducts.removeAll { $0.id == product.id }
    }
    
    // MARK: - Discounts
    func applyDiscountCode(_ code: String) -> Bool {
        let normalized = code.uppercased()
        if let percent = discountCodes[normalized] {
            appliedDiscountCode = normalized
            activeDiscountPercent = percent
            return true
        } else {
            appliedDiscountCode = nil
            activeDiscountPercent = 0.0
            return false
        }
    }
    
    func clearDiscount() {
        appliedDiscountCode = nil
        activeDiscountPercent = 0.0
        discountCleared.toggle()
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
