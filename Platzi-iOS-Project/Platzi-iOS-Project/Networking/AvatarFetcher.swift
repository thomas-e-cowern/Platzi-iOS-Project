//
//  AvatarFetcher.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/29/25.
//

import Foundation

class DataFetcher {
    var avatar: String = ""

    func fetchAvatar(id: Int) async -> String {
            // Replace with your actual API endpoint
            guard let url = URL(string: "https://avatar.iran.liara.run/public/\(id)") else { return "There was an error" }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedItem = try JSONDecoder().decode(String.self, from: data)
                self.avatar = decodedItem
                return avatar
            } catch {
                print("Error fetching or decoding items: \(error)")
            }
            
        return avatar
        }
    }
