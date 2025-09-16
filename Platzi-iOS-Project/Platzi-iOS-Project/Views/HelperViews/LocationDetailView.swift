//
//  LocationDetailView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/16/25.
//

import SwiftUI

struct LocationDetailView: View {
    
    var location: Location
    
    var body: some View {
        HStack(spacing: 5) {
            Image("PlatziIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.title)
                Text(location.description)
                    .font(.callout)
            }
        }
    }
}

#Preview {
    LocationDetailView(location: Location(id: 1, name: "123 Marina Street", description: "This store is in the marina district", latitude: 123.45, longitude: 123.45))
}
