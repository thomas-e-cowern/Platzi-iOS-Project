//
//  LoginView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/26/25.
//
import SwiftUI

struct LoginView: View {

    @Environment(\.authenticationService) private var authenticationService
    @Environment(\.presentNetworkError) private var presentNetworkError
    @Environment(\.userSession) private var userSession

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    @State private var email: String = "john@mail.com"
    @State private var password: String = "changeme"
    @State private var showRegisterView: Bool = false
    @State private var showEmployeeLogin: Bool = false
    @State private var isSubmitting: Bool = false

    // Invalid if email is empty/whitespace OR password fails your validation
    private var isFormInvalid: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || !password.isValidPassword
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .onSubmit { submitLogin() }
                }

                Button(action: submitLogin) {
                    HStack {
                        if isSubmitting { ProgressView().padding(.trailing, 6) }
                        Text("Login")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(isFormInvalid || isSubmitting ? .gray.opacity(0.2) : .green.opacity(0.2))
                    .foregroundStyle(isFormInvalid || isSubmitting ? .gray : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isFormInvalid || isSubmitting)

                if showEmployeeLogin {
                    Button {
                        showEmployeeLogin = false
                    } label: {
                        Text("Looking for customer login? click here…")
                    }
                } else {
                    Button {
                        showRegisterView = true
                    } label: {
                        Text("Don't have an account? Register here…")
                    }
                }
                
                if !showEmployeeLogin {
                    Button {
                        showEmployeeLogin = true
                    } label: {
                        Text("Looking for the employee login? click here…")
                    }
                } else {
                    
                }
            }
            .navigationTitle(showEmployeeLogin ? "Employee Login" : "Customer Login")
            .sheet(isPresented: $showRegisterView) {
                RegistrationView()
            }
        }
    }

    // MARK: - Actions
    
    private func submitLogin() {
        guard !isFormInvalid, !isSubmitting else { return }
        isSubmitting = true

        Task {
            do {
                // 1. Perform login
                let success = try await authenticationService.login(email: email, password: password)

                // 2. If successful, decide user role
                if success {
                    await MainActor.run {
                        // Example logic — replace with your backend role info
                        if showEmployeeLogin {
                            userSession.updateRole(.admin)
                            print("➡️➡️ \(userSession.role)")
                        } else {
                            userSession.updateRole(.customer)
                        }
                    }
                }

                // 3. Update login state
                await MainActor.run {
                    isLoggedIn = success
                    isSubmitting = false
                }

            } catch let e as NetworkError {
                await MainActor.run { isSubmitting = false }
                presentNetworkError(e, "Login Failed")

            } catch {
                await MainActor.run { isSubmitting = false }
                presentNetworkError(.transport(error), "Login Failed")
            }
        }
    }


//    private func submitLogin() {
//        guard !isFormInvalid, !isSubmitting else { return }
//        isSubmitting = true
//
//        Task {
//            do {
//                let success = try await authenticationService.login(email: email, password: password)
//                await MainActor.run {
//                    isLoggedIn = success
//                    isSubmitting = false
//                }
//            } catch let e as NetworkError {
//                await MainActor.run { isSubmitting = false }
//                // ✅ Show friendly error via environment-only presenter
//                presentNetworkError(e, "Login Failed")
//            } catch {
//                await MainActor.run { isSubmitting = false }
//                presentNetworkError(.transport(error), "Login Failed")
//            }
//        }
//    }
}


#Preview {
    LoginView()
}
