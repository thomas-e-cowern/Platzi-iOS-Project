//
//  Favorites.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/14/25.
//

import Foundation

import Foundation

@Observable
class Favorites { // Use ObservableObject for SwiftUI updates
    var favoriteIDs: Set<Int> // Store IDs of favorite items
    private let userDefaultsKey = "FavoritesList"

    init() {
        // Load favorite IDs from UserDefaults when the app starts
        if let savedIDs = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Int] {
            favoriteIDs = Set(savedIDs)
        } else {
            favoriteIDs = []
        }
    }

    func contains(_ itemID: Int) -> Bool {
        favoriteIDs.contains(itemID)
    }

    func add(_ itemID: Int) {
        favoriteIDs.insert(itemID)
        save()
    }

    func remove(_ itemID: Int) {
        favoriteIDs.remove(itemID)
        save()
    }

    private func save() {
        // Save the current set of favorite IDs to UserDefaults
        UserDefaults.standard.set(Array(favoriteIDs), forKey: userDefaultsKey)
    }
}
