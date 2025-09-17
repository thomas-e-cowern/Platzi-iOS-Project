//
//  HomeView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/5/25.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.authenticationService) private var authenticationService
    
    var body: some View {
        TabView {
            Tab("Category List", systemImage: "person") {
                NavigationStack {
                    CategoryListView()
                }
            }
            Tab("Location", systemImage: "pin") {
                NavigationStack {
                    LocationView()
                }
            }
            Tab("Profile", systemImage: "gear") {
                ProfileView()
            }
        } // MARK: - End of Tab
    }
}

#Preview {
    HomeView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
