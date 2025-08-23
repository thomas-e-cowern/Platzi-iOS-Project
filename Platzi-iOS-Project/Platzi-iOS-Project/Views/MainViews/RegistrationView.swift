//
//  RegistrationView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @Environment(\.authenticationService) private var authenticatinService
    
    @State private var registrationForm = RegistrationForm()
    @State private var errors: [String] = []
    @State private var responseMessage: String = ""
    
    // MARK: - Body
    var body: some View {
        Form {
            TextField("Name", text: $registrationForm.name)
            TextField("Email", text: $registrationForm.email)
            SecureField("Password must be 8 characters or longer", text: $registrationForm.password)
            Button("Register for Platzi") {
                errors = registrationForm.validate()
                if errors.isEmpty {
                    print("Registering...")
                    Task {
                        try await register()
                    }
                }
            }
//            .disabled(!registrationForm.isValid)
            
            if !errors.isEmpty {
                ValidationSummaryView(errors: errors)
            }
        }
    }
    
    // MARK: - Methods and functions
    func register() async throws {
        print("In register func in RegistrationView")
        let registrationResponse = try await authenticatinService.register(name: registrationForm.name, email: registrationForm.email, password: registrationForm.password)
        print("👉 RR: \(registrationResponse)")
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
