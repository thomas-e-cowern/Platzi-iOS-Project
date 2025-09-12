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
                    Text("Location Screen")
                }
            }
            Tab("Settings", systemImage: "gear") {
                VStack {
                    Text("This is the Settings View")
                    
                    Button("Sign out") {
                        authenticationService.signout()
                    }
                }
            }
        } // MARK: - End of Tab
    }
}

#Preview {
    HomeView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
