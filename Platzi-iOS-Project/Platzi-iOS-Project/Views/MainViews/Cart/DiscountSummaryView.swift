//
//  DiscountSummaryView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/15/25.
//

import SwiftUI

/// Shows current discount details + savings and final total.
/// Place this under your subtotal / DiscountEntryView.
struct DiscountSummaryView: View {
    @Environment(CartStore.self) private var cartStore

    private var baseTotal: Double { Double(cartStore.total) }
    private var employeePercent: Double { cartStore.userRole == "admin" ? 0.15 : 0.0 }
    private var codePercent: Double { cartStore.activeDiscountPercent }
    private var appliedPercent: Double { max(employeePercent, codePercent) }
    private var savings: Double { baseTotal * appliedPercent }
    private var final: Double { cartStore.finalTotal }

    private var sourceLabel: String {
        if appliedPercent == 0 { return "No discount applied" }
        if employeePercent >= codePercent && employeePercent > 0 {
            return "Employee (Admin) 15%"
        } else if let code = cartStore.appliedDiscountCode {
            let pct = (codePercent * 100).formatted(.number.precision(.fractionLength(0)))
            return "Code “\(code)” \(pct)%"
        } else {
            return "Discount \((appliedPercent * 100).formatted(.number.precision(.fractionLength(0))))%"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Discount")
                    .font(.headline)
                Spacer()
                Text(sourceLabel)
                    .font(.subheadline)
                    .foregroundStyle(appliedPercent > 0 ? .green : .secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Discount")
            .accessibilityValue(sourceLabel)

            if appliedPercent > 0 {
                HStack {
                    Text("You save")
                    Spacer()
                    Text(savings, format: .currency(code: "USD"))
                        .bold()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("You save")
                .accessibilityValue(Text(savings, format: .currency(code: "USD")))
            }

            Divider().padding(.vertical, 2)

            HStack {
                Text("Final Total")
                    .font(.headline)
                Spacer()
                Text(final, format: .currency(code: "USD"))
                    .font(.headline.weight(.semibold))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Final total")
            .accessibilityValue(Text(final, format: .currency(code: "USD")))

            if let code = cartStore.appliedDiscountCode {
                Button {
                    cartStore.clearDiscount()
                } label: {
                    Label("Clear Code \(code)", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Remove the applied discount code")
            }
        }
        .padding()
        .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }
}


#Preview {
    DiscountSummaryView()
}
