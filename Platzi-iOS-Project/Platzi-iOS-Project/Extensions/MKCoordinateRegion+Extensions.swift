//
//  MKCoordinateRegion+Extensions.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/15/25.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    static var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: .init(latitude: 37.3349, longitude: -122.0090),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}
