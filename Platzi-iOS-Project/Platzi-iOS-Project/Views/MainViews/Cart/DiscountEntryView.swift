//
//  DiscountEntryView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/15/25.
//

import SwiftUI

/// Simple entry row to apply a 4-character code (e.g., SAVE, DEAL, LUCK, GIFT).
struct DiscountEntryView: View {
    @Environment(CartStore.self) private var cartStore
    @State private var code: String = ""
    @State private var feedback: String?
    
    private var isValidLength: Bool {
        code.trimmingCharacters(in: .whitespaces).count == 4
    }
    
    private var codeCleared: Binding<String> {
        if cartStore.appliedDiscountCode != nil {
            return $code
        } else {
            return .constant("")
        }
        
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Enter 4-char code", text: $code)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .font(.body.monospacedDigit())
                    .textCase(.uppercase)
                    .submitLabel(.done)
                    .onSubmit(apply)
                    .accessibilityLabel("Enter discount code")
                
                Button("Apply") { apply() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidLength)
                    .accessibilityHint("Apply discount code")
            }
            
            if let feedback {
                Text((cartStore.appliedDiscountCode != nil) ? feedback : "")
                    .font(.footnote)
                    .foregroundStyle(feedback.contains("applied") ? .green : .red)
                    .accessibilityLabel(feedback)
            }
        }
        .onChange(of: cartStore.discountCleared) {
            code = ""
            feedback = nil
        }
    }
    
    private func apply() {
        let trimmed = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard trimmed.count == 4 else {
            feedback = "Code must be 4 characters."
            return
        }
        if cartStore.applyDiscountCode(trimmed) {
            feedback = "Code applied."
        } else {
            feedback = "Invalid code."
        }
    }
}


#Preview {
    DiscountEntryView()
}
