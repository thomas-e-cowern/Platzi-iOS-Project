//
//  AddCategoryView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/8/25.
//

import SwiftUI

struct AddCategoryView: View {
    
    @State private var isLoading: Bool = false
    @State private var name: String = ""
    @State private var imageUrl: String = "https://picsum.photos/640/480"
    
    private var isFormValid: Bool {
        !name.checkForEmptyOrWhitespace
    }
    
    @Environment(PlatziStore.self) private var platziStore
    
    var body: some View {
        Form {
            Section("Category Details") {
                TextField("Category Name", text: $name)
                TextField("Image URL", text: $imageUrl)
            }
            Section {
                HStack {
                    Button {
                        Task {
                            await addCategory()
                        }
                    } label: {
                        Label {
                            Text("Add Category")
                        } icon: {
                            Image(systemName: "checkmark.circle")
                        }
                        
                    }
                    .disabled(!isFormValid || isLoading)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Add Category")
    }
    
    // MARK: - Methods and functions
    private func addCategory() async {
        do {
            try await platziStore.addCategory(name: name, imageUrl: imageUrl)
        } catch {
            print("Error creating category: \(error.localizedDescription)")
        }
    }
    
    
}

#Preview {
    NavigationStack {
        AddCategoryView()
            .environment(PlatziStore(httpClient: HTTPClient()))
    }
}
