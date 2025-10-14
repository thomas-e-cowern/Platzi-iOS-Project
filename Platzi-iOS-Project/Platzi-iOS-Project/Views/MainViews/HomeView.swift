//
//  HomeView.swift
//  Platzi-iOS-Project
//
//  Created by Thomas Cowern on 9/5/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.authenticationService) private var authenticationService
    @Environment(CartStore.self) private var cartStore
//    @Environment(\.userSessionOptional) private var userSession
    @Environment(\.userSession) private var userSession

    var body: some View {
        TabView {
            Tab("Category List", systemImage: "person") {
                NavigationStack { CategoryListView() }
            }
            Tab("Location", systemImage: "pin") {
                NavigationStack { LocationView() }
            }

            if userSession.role == .customer {
                Tab("Cart", systemImage: "cart") { CartView() }
                    .badge(cartStore.cartProducts.count)
            }
            
            if userSession.role == .customer {
                Tab("Favorites", systemImage: "heart.fill") {
                    NavigationStack {
                        FavoritesView()
                    }
                }
            }

            Tab("Profile", systemImage: "gear") { ProfileView() }
        }
    }
}


#Preview("Customer") {
    HomeView()
        .environment(\.userSessionOptional, {
            let s = UserSession()
            s.updateRole(.customer)
            return s
        }())
        .environment(CartStore())
}

#Preview("Employee") {
    HomeView()
        .environment(\.userSessionOptional, {
            let s = UserSession()
            s.updateRole(.admin)
            return s
        }())
        .environment(CartStore())
}

