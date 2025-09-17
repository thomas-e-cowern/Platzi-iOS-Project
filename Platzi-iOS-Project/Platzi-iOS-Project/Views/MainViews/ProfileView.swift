//
//  ProfileView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/17/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.authenticationService) private var authenticationService
    
    var body: some View {
        Button("Sign out") {
            authenticationService.signout()
        }
    }
}

#Preview {
    ProfileView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
