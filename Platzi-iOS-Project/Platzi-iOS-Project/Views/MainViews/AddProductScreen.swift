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
    @State private var categoryId: Int
    @State private var image: [String] = []
    
    let onSave: (Product) -> Void
    
    init(categoryId: Int, onSave: @escaping(Product) -> Void) {
        self.categoryId = categoryId
        self.onSave = onSave
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
            
            TextField("Title", text: $title)
            TextField("Price", value: $price, format: .number)
            TextEditor(text: $description)
                .frame(minHeight: 100)
            
            
        }
        .task {
            do {
                try await platziStore.loadCategories()
            } catch {
                print("Error in AddProductScreen loadCategories: \(error.localizedDescription)")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }

            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await saveProduct()
                    }
                } label: {
                    Text("Save Product")
                }

            }
        }
    }
    
    // MARK: - Methods and functions
    func saveProduct() async {
        Task {
            do {
                let newProduct = try await platziStore.addProduct(title: title, price: Int(price), description: description, categoryId: categoryId, images: [String.randomImageString])
                
                onSave(newProduct)
                dismiss()
            } catch {
                print("Error adding Product: \(error.localizedDescription)")
            }
            
        }
    }
}

#Preview {
    NavigationStack {
        AddProductScreen(categoryId: 1, onSave: { _ in })
            .environment(PlatziStore(httpClient: HTTPClient()))
    }
}
