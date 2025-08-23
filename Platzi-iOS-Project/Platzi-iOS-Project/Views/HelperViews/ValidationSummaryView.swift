//
//  ValidationSummaryView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 8/23/25.
//

import SwiftUI

struct ValidationSummaryView: View {
    let errors: [String]

    var body: some View {
        Group {
            if errors.isEmpty {
                successView
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)),
                                            removal: .opacity))
            } else {
                errorListView
                    .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                                            removal: .opacity))
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.15), value: errors)
    }

    
    // MARK: - Subviews
    private var successView: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text("All set")
                    .font(.headline)
                Text("No validation issues found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.green.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Validation passed. No issues.")
    }

    private var errorListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("Please fix \(errors.count) issue\(errors.count == 1 ? "" : "s")")
                    .font(.headline)
                Spacer()
                // Count badge
                Text("\(errors.count)")
                    .font(.footnote.weight(.semibold))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        Capsule().fill(Color.yellow.opacity(0.15))
                    )
                    .overlay(
                        Capsule().stroke(Color.yellow.opacity(0.35), lineWidth: 1)
                    )
                    .accessibilityHidden(true)
            }

            // Error rows
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(errors.enumerated()), id: \.offset) { _, error in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "xmark.octagon.fill")
                            .foregroundStyle(.red)
                            .font(.body)

                        Text(error)
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.red.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.red.opacity(0.18), lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Error: \(error)")
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

// MARK: - Previews

#Preview("Empty (Success)") {
    ValidationSummaryView(errors: [])
        .padding()
}

#Preview("With Errors") {
    ValidationSummaryView(errors: [
        "Title can’t be empty.",
        "Reason must be at least 20 characters long.",
        "Date cannot be in the future.",
        "Please choose an icon color."
    ])
    .padding()
}
