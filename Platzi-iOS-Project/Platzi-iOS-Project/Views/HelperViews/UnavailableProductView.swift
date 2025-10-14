//
//  UnavailableProducts.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/14/25.
//

import SwiftUI

struct UnavailableProductView: View {
    @Environment(\.dismiss) private var dismiss

    let productId: Int
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))

            Text("This product is no longer available.")
                .font(.title3).bold()
                .multilineTextAlignment(.center)

            Text("It may have been removed, out of stock permanently, or the link is invalid.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(role: .destructive) {
                onRemove()
                dismiss()
            } label: {
                Label("Remove from Favorites", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)

            Spacer()
        }
        .padding()
        .navigationTitle("Unavailable")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Product unavailable. Remove from favorites.")
    }
}

#Preview {
    UnavailableProductView(productId: 1, onRemove: {})
}
