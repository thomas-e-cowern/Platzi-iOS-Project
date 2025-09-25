//
//  Platzi_iOS_ProjectApp.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import SwiftUI

@main
struct Platzi_iOS_ProjectApp: App {
    
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.authenticationService) private var authenticationService
    @State private var isLoading: Bool = true
    @State private var cartStore = CartStore()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    ProgressView {
                        Text("Loading...")
                    }
                    .task {
                        isLoggedIn = await authenticationService.checkLoggedInStatus()
                        print("isLoggedIn is \(isLoggedIn)")
                        isLoading = false
                    }
                } else if isLoggedIn {
                    HomeView()
                        .environment(PlatziStore(httpClient: HTTPClient()))
                        .environment(cartStore)
                } else {
                    LoginView()
                }
            }
        }
    }
}
