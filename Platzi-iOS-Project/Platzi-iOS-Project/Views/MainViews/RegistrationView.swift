//
//  RegistrationView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import SwiftUI

struct RegistrationView: View {
    
    // MARK: - Properties
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var role: String = "customer"
    @State private var avatar: String = "https://avatar.iran.liara.run/public/41"
    
    var isValid: Bool {
        return validate().isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Register for Platzi") {
                
            }
            .disabled(!isValid)
        }
    }
    
    // MARK: - Methods and functions
    func validate() -> [String] {
        
        var errors: [String] = []
        
        if name.checkForEmptyOrWhitespace {
            errors.append("Name cannot be empty.")
        }
        
        if email.checkForEmptyOrWhitespace {
            errors.append("Email cannot be empty.")
        }
        
        if password.checkForEmptyOrWhitespace {
            errors.append("Password cannot be empty.")
        }
        
        if !password.isValidPassword {
            errors.append("Password must be at least 8 characters long.")
        }
        
        if !email.isEmail {
            errors.append("Email must be in correct format.")
        }
        
        return errors
    }
}


#Preview {
    RegistrationView()
}
