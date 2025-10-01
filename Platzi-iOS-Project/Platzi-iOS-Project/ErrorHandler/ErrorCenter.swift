//
//  ErrorCenter.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/1/25.
//

import SwiftUI
import Combine
import Observation

// A simple envelope for alerts
struct AppAlert: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let debug: String?
}

@Observable
final class ErrorCenter {
    var alert: AppAlert?

    func present(_ error: NetworkError, title: String = "Something went wrong") {
        alert = AppAlert(
            title: title,
            message: error.errorDescription ?? "Unknow Error",        // ← user-friendly
            debug: error.localizedDescription     // ← developer-friendly
        )
        // Optional: log debug info
        #if DEBUG
        if let debug = alert?.debug {
            print("⚠️ ERROR:", debug)
        }
        #endif
    }

    // Convenience: present any Error (maps to NetworkError when possible)
    func present(_ error: Error, title: String = "Something went wrong") {
        if let net = error as? NetworkError {
            present(net, title: title)
        } else {
            alert = AppAlert(
                title: title,
                message: "Unexpected error. Please try again.",
                debug: error.localizedDescription
            )
            #if DEBUG
            print("⚠️ ERROR:", error.localizedDescription)
            #endif
        }
    }

    /// Run an async operation and automatically present any thrown errors.
    func run(_ op: @escaping () async throws -> Void) {
        Task {
            do { try await op() }
            catch { self.present(error) }
        }
    }
}

