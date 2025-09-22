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
    var cartProducts: [Product] = []
    
    func addProduct(_ product: Product) {
        cartProducts.append(product)
        // You might want to handle quantity updates if the same product is added multiple times
    }
    
    func removeProduct(_ product: Product) {
        if let index = cartProducts.firstIndex(of: product) {
            cartProducts.remove(at: index)
        }
    }
    
    var total: Int {
        cartProducts.reduce(0) { $0 + $1.price }
    }
    
}
