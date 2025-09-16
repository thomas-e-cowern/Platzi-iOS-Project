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
    @State private var selectedLocation: Location?
    @State private var showDetailView: Bool = false
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(platziStore.locations) { location in
                let isSelected = selectedLocation?.id == location.id
                let pinColor: Color = isSelected ? .red : .blue
                let pinFont: Font = isSelected ? .largeTitle : .title
                let pinScale: CGFloat = isSelected ? 1.5 : 1.0

                Annotation(location.name, coordinate: location.coordinates) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(pinColor)
                        .font(pinFont)
                        .scaleEffect(pinScale)
                        .animation(.spring(), value: selectedLocation?.id)
                        .onTapGesture {
                            selectedLocation = location
                            showDetailView.toggle()
                        }
                }
            }
        }
        .sheet(isPresented: $showDetailView, content: {
            HStack(spacing: 5) {
                Image("PlatziIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
                    .padding(.trailing, 5)
                VStack(alignment: .leading) {
                    Text(selectedLocation?.name ?? "No location selected")
                        .font(.title)
                    Text(selectedLocation?.description ?? "No location selected")
                        .font(.callout)
                }
            }
        })
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
