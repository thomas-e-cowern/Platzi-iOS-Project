//
//  ProductDetailView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/10/25.
//

import SwiftUI

struct ProductDetailView: View {
    
    var product: Product
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ProductDetailView(product: Product(id: 86, title: "Classic Red Pullover Hoodie", slug: "classic-red-pullover-hoodie", price: 10, description: "Elevate your casual wardrobe with our Classic Red Pullover Hoodie. Crafted with a soft cotton blend for ultimate comfort, this vibrant red hoodie features a kangaroo pocket, adjustable drawstring hood, and ribbed cuffs for a snug fit. The timeless design ensures easy pairing with jeans or joggers for a relaxed yet stylish look, making it a versatile addition to your everyday attire.", category: Category(id: 31, name: "Clothes", slug: "clothes", image: "https://i.imgur.com/QkIa5tT.jpeg"),
        images:
        [
        "https://i.imgur.com/1twoaDy.jpeg",
        "https://i.imgur.com/FDwQgLy.jpeg",
        "https://i.imgur.com/kg1ZhhH.jpeg"
        ]
      )
    )
}
