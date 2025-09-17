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
        ZStack {
            
            Button {
                authenticationService.signout()
            } label: {
                Text("Sign Out")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.red.opacity(0.2)))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            
        }
    }
}

#Preview {
    ProfileView()
        .environment(PlatziStore(httpClient: HTTPClient()))
}
