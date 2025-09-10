//
//  ProductDetailImageView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/10/25.
//

import SwiftUI

struct ProductDetailImageView: View {
    
    var images: [String]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(images, id: \.self) { imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        ImagePlaceholderView()
                            .frame(width: 200)
                            .overlay(ProgressView())
                    }

                }
            }
        }
    }
}

#Preview {
    ProductDetailImageView(images:
                            [
                                "https://i.imgur.com/1twoaDy.jpeg",
                                "https://i.imgur.com/FDwQgLy.jpeg",
                                "https://i.imgur.com/kg1ZhhH.jpeg"
                            ])
}
