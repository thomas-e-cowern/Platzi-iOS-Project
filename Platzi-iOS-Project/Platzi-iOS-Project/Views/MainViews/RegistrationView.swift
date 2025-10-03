//
//  RegistrationView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/22/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @Environment(\.authenticationService) private var authenticatinService
    @Environment(\.dismiss) private var dismiss
    
    @State private var registrationForm = RegistrationForm()
    @State private var errors: [String] = []
    @State private var responseMessage: String?
    @State private var selectedItem: String = ""
    @State private var avatar: String?
    @State private var isClicked: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $registrationForm.name)
                TextField("Email", text: $registrationForm.email)
                SecureField("Password must be 8 characters or longer", text: $registrationForm.password)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(1..<25) { index in
                            AsyncImage(url: URL(string: "https://avatar.iran.liara.run/public/\(index)")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        Circle()
                                            .stroke(selectedItem.contains("\(index)") ? Color.red : Color.clear, lineWidth: 5) // Adds a rounded border
                                    )
                                    .onTapGesture {
                                        selectedItem = "https://avatar.iran.liara.run/public/\(index)"
                                        isClicked.toggle()
                                    }
                            } placeholder: {
                                ImagePlaceholderView()
                                    .frame(width: 200)
                                    .overlay(ProgressView())
                            }
                        }
                    }
                    .padding(.horizontal) // Add horizontal padding to the entire HStack
                }
                Text(selectedItem)
                
                Button {
                    errors = registrationForm.validate()
                    if errors.isEmpty {
                        print("Registering...")
                        Task {
                            await register()
                            dismiss()
                        }
                    }
                } label: {
                    Text("Register for Platzi")
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!registrationForm.isValid ? .gray.opacity(0.2) : .green.opacity(0.2))
                        .foregroundStyle(!registrationForm.isValid ? .gray : .green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!registrationForm.isValid)
                
                if !errors.isEmpty {
                    ValidationSummaryView(errors: errors, isValidationErrors: true)
                }
                
                if responseMessage != nil {
                    ValidationSummaryView(errors: [], isValidationErrors: false)
                }
            }
            .navigationTitle("Register")
        }
        
        
    }
    
    // MARK: - Methods and functions
    func register() async {
        do {
            _ = try await authenticatinService.register(name: registrationForm.name, email: registrationForm.email, password: registrationForm.password, avatar: selectedItem)
            
            responseMessage = "registration for \(registrationForm.name) successful"
            
            registrationForm = .init()
        } catch {
            responseMessage = error.localizedDescription
        }
        
    }
    
    func getUrlFromString(string: String) -> URL? {
        guard let url = URL(string: string) else {
            return nil
        }
        
        return url
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
