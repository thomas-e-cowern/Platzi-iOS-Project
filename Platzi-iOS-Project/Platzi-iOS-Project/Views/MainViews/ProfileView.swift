//
//  ProfileView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/17/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.authenticationService) private var authenticationService
    
    @Environment(\.runWithErrorHandling) private var runWithErrorHandling
    @Environment(\.presentNetworkError) private var presentNetworkError
    
    @State var userProfile: UserProfile?
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                
                VStack {
                    if let avatar = userProfile?.avatar, let url = URL(string: avatar) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } placeholder: {
                            ImagePlaceholderView()
                                .frame(width: 200)
                                .overlay(ProgressView())
                        }
                    } else {
                        ImagePlaceholderView()
                            .frame(width: 200)
                    }
                    
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
                    
                    DebugErrorButton()
                }
                .onAppear {
                    Task {
                        await getUserProfile()
                    }
                }
                
            }
            .navigationTitle("Profile")
        }
    }
    
    func getUserProfile() async -> UserProfile? {
        do {
            await authenticationService.probeProfileDirect()
            userProfile = try await authenticationService.getUserProfile()
            return userProfile
        } catch let e as NetworkError {
            presentNetworkError(e, "Profile Error")
        } catch {
            presentNetworkError(.transport(error), "Profile Error")
        }
        return nil
    }
    
}

#Preview {
    ProfileView(userProfile: UserProfile(id: 1, name: "John Smith", email: "js@email.com", password: "qgwtfdflgasd", role: "customer", avatar: ""))
        .environment(PlatziStore(httpClient: HTTPClient()))
}
