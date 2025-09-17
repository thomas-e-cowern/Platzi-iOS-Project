//
//  LoginView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/26/25.
//

import SwiftUI

struct LoginView: View {
    
    @Environment(\.authenticationService) private var authSerivce
    
    @State private var email: String = "john@mail.com"
    @State private var password: String = "changeme"
    @State private var showRegisterView: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    private var isFormValid: Bool {
        !email.checkForEmptyOrWhitespace && !password.isValidPassword
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                }
                
                Button {
                    Task {
                        await login()
                    }
                } label: {
                    Text("Login")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ?  .gray.opacity(0.2) : .green.opacity(0.2))
                        .foregroundStyle(isFormValid ? .gray : .green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isFormValid)
                
                Button {
                    showRegisterView = true
                } label: {
                    Text("Don't have an account? Register here...")
                }

            }
            .navigationTitle("Login")
            .sheet(isPresented: $showRegisterView) {
                RegistrationView()
            }
        }
    }
    
    // MARK: - Methods and functions
    private func login() async {
        do {
            isLoggedIn = try await authSerivce.login(email: email, password: password)
        } catch {
            print("Error logging in in LoginView: \(error.localizedDescription)")
        }
        
    }
}

#Preview {
    LoginView()
}
