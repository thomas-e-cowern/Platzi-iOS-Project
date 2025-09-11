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
    @State private var categoryId: Int = 1
    @State private var image: [String] = []
    
    init(categoryId: Int) {
        self.categoryId = categoryId
    }
    
    var body: some View {
        Form {
            Picker("Select Category", selection: $categoryId) {
                ForEach(platziStore.categories) { category in
                    Text(category.name)
                        .tag(category.id)
                }
            }
            .pickerStyle(.automatic)
        }
        .task {
            do {
                try await platziStore.loadCategories()
            } catch {
                print("Error in AddProductScreen loadCategories: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    AddProductScreen(categoryId: 1)
        .environment(PlatziStore(httpClient: HTTPClient()))
}
