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
                        .font(.title)
                }
            }
        }
        .task {
            do {
                _ = try await platziStore.loadLocations()
                
                let coordinates = platziStore.locations.map { $0.coordinates }
                if let region = regionThatFits(coordinates) {
                    cameraPosition = .region(region)
                }
            } catch {
                print("Error loading locations in LocationView: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Methods and functions
    private func regionThatFits(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }
        
        let mapRect = coordinates.reduce(MKMapRect.null) { rect, coord in
            let point = MKMapPoint(coord)
            let pointRect = MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0))
            return rect.union(pointRect)
        }
        
        return MKCoordinateRegion(mapRect)
    }
}

#Preview {
    LocationView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
