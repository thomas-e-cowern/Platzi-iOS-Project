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
    
    var body: some View {
        Map()
    }
}

#Preview {
    LocationView()
}
