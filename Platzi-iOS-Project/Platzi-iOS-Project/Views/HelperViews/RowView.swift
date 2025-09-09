//
//  RowView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/9/25.
//

import SwiftUI

struct RowView: View {
    
    var title: String
    var imageUrl: String
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ImagePlaceholderView()
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(title)
                .font(.headline)
        }
    }
}

#Preview {
    RowView(title: "Shoes", imageUrl: "https://picsum.photos/200")
}
