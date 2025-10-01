//
//  ErrorPresenter.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 10/1/25.
//

import SwiftUI

struct ErrorPresenter<Content: View>: View {
    @State private var currentAlert: AppAlert?
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .environment(\.presentAlert) { alert in
                Task { @MainActor in currentAlert = alert }
            }
            .environment(\.presentNetworkError) { error, title in
                Task { @MainActor in
                    currentAlert = AppAlert(
                        title: title,
                        message: error.errorDescription ?? "Unknown Error",
                        debug: error.localizedDescription
                    )
                }
            }
            .environment(\.runWithErrorHandling) { op in
                Task {
                    do { try await op() }
                    catch let e as NetworkError {
                        await MainActor.run {
                            currentAlert = AppAlert(
                                title: "Something went wrong",
                                message: e.errorDescription ?? "Unknown Error",
                                debug: e.localizedDescription
                            )
                        }
                    } catch {
                        await MainActor.run {
                            currentAlert = AppAlert(
                                title: "Something went wrong",
                                message: "Unexpected error. Please try again.",
                                debug: error.localizedDescription
                            )
                        }
                    }
                }
            }
            // iOS 16/17 compatible alert
            .alert(item: $currentAlert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK")) { currentAlert = nil }
                )
            }
    }
}

struct DebugErrorButton: View {
    @Environment(\.presentAlert) private var presentAlert
    var body: some View {
        Button("Trigger Test Error") {
            presentAlert(.init(title: "Test", message: "Hello from Environment", debug: nil))
        }
    }
}
