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
    
    var body: some View {
        ZStack {
            if platziStore.categories.isEmpty && !isLoading {
                ContentUnavailableView("No Categories Available", systemImage: "shippingbox")
            } else {
                List(platziStore.categories) { category in
                    HStack(spacing: 15) {
                        AsyncImage(url: URL(string: category.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } placeholder: {
                            ImagePlaceholderView()
                        }
                        .frame(width: 50, height: 50)
                        
                        Text(category.name)
                            .font(.headline)
                    }
                }
                .overlay(alignment: .center, content: {
                    if isLoading {
                        ProgressView("Loading...")
                    }
                })
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
            print("isLoading: \(isLoading)")
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
