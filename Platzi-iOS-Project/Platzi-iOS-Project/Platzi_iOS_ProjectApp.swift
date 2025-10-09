import SwiftUI

@main
struct Platzi_iOS_ProjectApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @Environment(\.authenticationService) private var authenticationService

    @State private var isLoading = true
    @State private var cartStore = CartStore()
    @State private var session = UserSession()    // @MainActor

    var body: some Scene {
        WindowGroup {
            // Everything is inside this one root
            RootContainer(isLoading: $isLoading, isLoggedIn: $isLoggedIn)
                // 🔑 Inject here (directly on the view returned by WindowGroup)
                .environment(\.userSessionOptional, session)
                .environment(PlatziStore(httpClient: HTTPClient()))
                .environment(cartStore)
                .environment(MockPlatziStore())
        }
    }
}

private struct RootContainer: View {
    @Binding var isLoading: Bool
    @Binding var isLoggedIn: Bool
    @Environment(\.authenticationService) private var authenticationService

    var body: some View {
        ErrorPresenter {
            ZStack {
                EnvProbe()  // <- add our probe here

                if isLoading {
                    ProgressView { Text("Loading...") }
                        .task {
                            isLoggedIn = await authenticationService.checkLoggedInStatus()
                            isLoading = false
                        }
                } else if isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

private struct EnvProbe: View {
    @Environment(\.userSessionOptional) private var session  // <- THIS is the right way

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                print("🔎 userSession present at root? \(session != nil)")
                print("User is a \(String(describing: session?.role))")
            }
    }
}
