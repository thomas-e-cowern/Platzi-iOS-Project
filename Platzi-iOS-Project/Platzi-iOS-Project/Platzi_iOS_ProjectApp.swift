import SwiftUI

@main
struct Platzi_iOS_ProjectApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @Environment(\.authenticationService) private var authenticationService
    @State private var isLoading: Bool = true
    @State private var cartStore = CartStore()
    @State private var session = UserSession()

    var body: some Scene {
        WindowGroup {
            // ✅ Install once at the very top of your view tree
            ErrorPresenter {
                ZStack {
                    if isLoading {
                        ProgressView { Text("Loading...") }
                            .task {
                                // If this can throw and you want a UI error here,
                                // move this into a child view that can use
                                // `@Environment(\.runWithErrorHandling)` or call
                                // one of the injected closures.
                                isLoggedIn = await authenticationService.checkLoggedInStatus()
                                print("isLoggedIn is \(isLoggedIn)")
                                isLoading = false
                            }

                    } else if isLoggedIn {
                        HomeView()
                            .environment(PlatziStore(httpClient: HTTPClient()))
                            .environment(cartStore)
                            .environment(MockPlatziStore())
                            .environment(session)

                    } else {
                        LoginView()
                    }
                }
            }
        }
    }
}
