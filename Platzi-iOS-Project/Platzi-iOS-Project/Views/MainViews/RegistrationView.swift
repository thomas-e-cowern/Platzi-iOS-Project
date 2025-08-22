//
//  RegistrationView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var role: String = "customer"
    @State private var avatar: String = "https://avatar.iran.liara.run/public/41"
    
    @State private var errors: [String] = []
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Register for Platzi") {
                
            }
        }
    }
    
    private func validate() -> [String] {
        
        if name.checkForEmptyOrWhitespace {
            errors.append("Please enter a name")
        }
        
        if email.checkForEmptyOrWhitespace {
            errors.append("Please enter an email")
        }
        
        if !email.isEmail {
            errors.append("Please enter a valid email")
        }
        
        if !password.isValidPassword {
            errors.append("Password must be at least 8 characters long")
        }
        
        return errors
    }
}

#Preview {
    RegistrationView()
}
