//
//  ImagePlaceholderView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/6/25.
//

import SwiftUI

struct ImagePlaceholderView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 50, height: 50)
            Image(systemName: "photo")
        }
    }
}

// MARK: - Preview
#Preview {
    ImagePlaceholderView()
}
