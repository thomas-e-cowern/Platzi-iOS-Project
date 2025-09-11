//
//  AddProductScreen.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/11/25.
//

import SwiftUI

struct AddProductScreen: View {
    
    @Environment(PlatziStore.self) private var platziStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var price: Double = 0
    @State private var description: String = ""
    @State private var category: Int = 1
    @State private var image: [String] = []
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AddProductScreen()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
