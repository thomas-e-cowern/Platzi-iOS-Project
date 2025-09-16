//
//  LocationDetailView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/16/25.
//

import SwiftUI
import _MapKit_SwiftUI

struct LocationDetailView: View {
    
    var location: Location
    @State private var cameraPosition: MapCameraPosition
    
    init(location: Location) {
        self.location = location
        let region = MKCoordinateRegion(center: location.coordinates, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        cameraPosition = MapCameraPosition.region(region)
    }
    
    var body: some View {
        VStack {
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
            .padding(.top, 18)
            Map(position: $cameraPosition) {
                Marker(location.name, coordinate: location.coordinates)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
        .background(Color.white)
    }
}

#Preview {
    LocationDetailView(location: Location(id: 1, name: "123 Marina Street", description: "This store is in the marina district", latitude: 123.45, longitude: 123.45))
}
