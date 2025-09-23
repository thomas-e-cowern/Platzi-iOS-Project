//
//  CartInfoView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/23/25.
//

import SwiftUI

struct CartInfoView: View {
    // MARK: - Shipping
    @State private var shipName = ""
    @State private var shipAddress1 = ""
    @State private var shipAddress2 = ""
    @State private var shipCity = ""
    @State private var shipState = ""
    @State private var shipZip = ""

    // MARK: - Billing
    @State private var billingSameAsShipping = true
    @State private var billName = ""
    @State private var billAddress1 = ""
    @State private var billAddress2 = ""
    @State private var billCity = ""
    @State private var billState = ""
    @State private var billZip = ""

    // MARK: - Card
    @State private var cardHolder = "First Last"
    @State private var cardNumber = "4242424242424242"
    @State private var expMonth = "01"
    @State private var expYear = "1977"
    @State private var cvv = "1234"

    // MARK: - UI
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Shipping Address") {
                    AddressFields(
                        name: $shipName,
                        address1: $shipAddress1,
                        address2: $shipAddress2,
                        city: $shipCity,
                        state: $shipState,
                        zip: $shipZip
                    )
                }

                Section {
                    Toggle("Billing same as shipping", isOn: $billingSameAsShipping)
                        .onChange(of: billingSameAsShipping) { _, isOn in
                            if isOn {
                                copyShippingToBilling()
                            }
                        }
                        .onAppear {
                            // Initialize billing with shipping if toggle starts on
                            if billingSameAsShipping { copyShippingToBilling() }
                        }
                }

                if !billingSameAsShipping {
                    Section("Billing Address") {
                        AddressFields(
                            name: $billName,
                            address1: $billAddress1,
                            address2: $billAddress2,
                            city: $billCity,
                            state: $billState,
                            zip: $billZip
                        )
                    }
                }

                Section("Payment") {
                    TextField("Cardholder name", text: $cardHolder)
                        .textContentType(.name)
                        .autocapitalization(.words)

                    TextField("Card number", text: $cardNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.creditCardNumber)
                        .onChange(of: cardNumber) { _, new in
                            cardNumber = formatCardNumber(new)
                        }
                        .accessibilityLabel("Credit card number")

                    HStack(spacing: 12) {
                        TextField("MM", text: $expMonth)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("Expiration month")

                        Text("/")
                            .foregroundStyle(.secondary)

                        TextField("YY", text: $expYear)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("Expiration year")

                        SecureField("CVV", text: $cvv)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("Security code")
                    }
                }
                .disabled(true)

                Section {
                    Button {
                        submit()
                    } label: {
                        Text("Submit Order")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } footer: {
                    Text("If this were a real app, this would be sent to be verified and your order would be placed.")
                }
            }
            .navigationTitle("Checkout")
            .alert("Check your info", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Helpers

    private func copyShippingToBilling() {
        billName = shipName
        billAddress1 = shipAddress1
        billAddress2 = shipAddress2
        billCity = shipCity
        billState = shipState
        billZip = shipZip
    }

    private func submit() {
        // Basic field presence checks
        let billingOK: Bool = {
            if billingSameAsShipping { return required(shipName, shipAddress1, shipCity, shipState, shipZip) }
            return required(billName, billAddress1, billCity, billState, billZip)
        }()

        guard required(shipName, shipAddress1, shipCity, shipState, shipZip) else {
            show("Please fill out all required shipping fields.")
            return
        }
        guard billingOK else {
            show("Please fill out all required billing fields.")
            return
        }
        guard required(cardHolder, cardNumber, expMonth, expYear, cvv) else {
            show("Please complete your payment details.")
            return
        }
        guard isValidExpiry(mm: expMonth, yy: expYear) else {
            show("Expiration date looks invalid. Use MM / YY.")
            return
        }
        guard luhnIsValid(cardNumber.filter(\.isNumber)) else {
            show("Card number doesn’t look valid.")
            return
        }
        guard cvv.trimmingCharacters(in: .whitespaces).count >= 3 else {
            show("CVV should be at least 3 digits.")
            return
        }

        // ✅ At this point, you’d tokenize/send to your payment processor.
        show("Looks good! In a real app, this is where your oreder would be place.....")
    }

    private func required(_ fields: String...) -> Bool {
        fields.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func show(_ msg: String) {
        alertMessage = msg
        showAlert = true
    }

    // Luhn check for card number sanity
    private func luhnIsValid(_ digits: String) -> Bool {
        guard !digits.isEmpty, digits.allSatisfy(\.isNumber) else { return false }
        let reversed = digits.reversed().compactMap { Int(String($0)) }
        let sum = reversed.enumerated().reduce(0) { acc, pair in
            let (idx, num) = pair
            if idx % 2 == 1 {
                let doubled = num * 2
                return acc + (doubled > 9 ? doubled - 9 : doubled)
            } else {
                return acc + num
            }
        }
        return sum % 10 == 0
    }

    // Format "4242424242424242" -> "4242 4242 4242 4242"
    private func formatCardNumber(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(19) // allow up to 19 for some cards
        return stride(from: 0, to: digits.count, by: 4).map { start in
            let end = min(start + 4, digits.count)
            let s = digits.dropFirst(start).prefix(end - start)
            return String(s)
        }.joined(separator: " ")
    }

    // Accepts MM / YY and checks if in the future (simple, not timezone-sensitive)
    private func isValidExpiry(mm: String, yy: String) -> Bool {
        guard let m = Int(mm), (1...12).contains(m),
              let y2 = Int(yy) else { return false }

        // Interpret YY in 2000-2099
        let year = 2000 + y2
        let now = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: now)
        guard let curY = comps.year, let curM = comps.month else { return false }

        if year > curY { return true }
        if year == curY { return m >= curM }
        return false
    }
}

private struct AddressFields: View {
    @Binding var name: String
    @Binding var address1: String
    @Binding var address2: String
    @Binding var city: String
    @Binding var state: String
    @Binding var zip: String

    var body: some View {
        TextField("Full name", text: $name)
            .textContentType(.name)
            .autocapitalization(.words)

        TextField("Address line 1", text: $address1)
            .textContentType(.fullStreetAddress)
        TextField("Address line 2 (optional)", text: $address2)

        HStack {
            TextField("City", text: $city)
                .textContentType(.addressCity)
            TextField("State", text: $state)
                .textContentType(.addressState)
                .frame(width: 80)
                .textInputAutocapitalization(.characters)
        }

        TextField("ZIP", text: $zip)
            .textContentType(.postalCode)
            .keyboardType(.numbersAndPunctuation)
    }
}

// MARK: - Preview
#Preview {
    CartInfoView()
}
