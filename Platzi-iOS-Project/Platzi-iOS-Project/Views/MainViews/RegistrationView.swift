//
//  RegistrationView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var registrationForm = RegistrationForm()
    @State private var errors: [String] = []
    
    // MARK: - Body
    var body: some View {
        Form {
            TextField("Name", text: $registrationForm.name)
            TextField("Email", text: $registrationForm.email)
            SecureField("Password must be 8 characters or longer", text: $registrationForm.password)
            Button("Register for Platzi") {
                errors = registrationForm.validate()
            }
//            .disabled(!registrationForm.isValid)
            
            if !errors.isEmpty {
                ValidationSummaryView(errors: errors)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    RegistrationView()
}

struct RegistrationForm {
    
    // MARK: - Properties
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var role: String = "customer"
    var avatar: String = "https://avatar.iran.liara.run/public/41"
    
    var isValid: Bool {
        return validate().isEmpty
    }
    
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
