//
//  CategoryListView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/6/25.
//

import SwiftUI

struct CategoryListView: View {
    
    @Environment(PlatziStore.self) private var platziStore
    @State private var isLoading: Bool = false
    @State private var showAddCategoryView: Bool = false
    
    var body: some View {
        ZStack {
            if platziStore.categories.isEmpty && !isLoading {
                ContentUnavailableView("No Categories Available", systemImage: "shippingbox")
            } else {
                List(platziStore.categories) { category in
                    NavigationLink {
                        ProductListScreen(category: category)
                    } label: {
                        RowView(title: category.name, imageUrl: category.image)
                    }

                }
                .overlay(alignment: .center, content: {
                    if isLoading {
                        ProgressView("Loading...")
                    }
                })
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Category") {
                    showAddCategoryView.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddCategoryView, content: {
            NavigationStack {
                AddCategoryView()
            }
        })
        .overlay {
            if isLoading {
                ProgressView("Loading...")
            }
        }
        .task {
            await loadCategories()
        }
        .navigationTitle("Categories")
    }
    
    // MARK: - Methods and functions
    private func loadCategories() async {
        
        defer { isLoading = false }
        
        do {
            isLoading = true
            try await platziStore.loadCategories()
        } catch {
            print("Error loading categories: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        CategoryListView()
    }
    .environment(PlatziStore(httpClient: HTTPClient()))
}
