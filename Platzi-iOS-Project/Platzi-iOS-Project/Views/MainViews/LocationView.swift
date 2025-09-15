//
//  LocationView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/15/25.
//

import SwiftUI
import MapKit

struct LocationView: View {
    
    @State private var cameraPosition = MapCameraPosition.region(.defaultRegion)
    @Environment(PlatziStore.self) private var platziStore
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(platziStore.locations) { location in
                Annotation(location.name, coordinate: location.coordinates) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.red)
                }
            }
        }
        .task {
            do {
                _ = try await platziStore.loadLocations()
            } catch {
                print("Error loading locations in LocationView: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LocationView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
