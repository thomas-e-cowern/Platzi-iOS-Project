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
        
    }
}

#Preview {
    RegistrationView()
}
