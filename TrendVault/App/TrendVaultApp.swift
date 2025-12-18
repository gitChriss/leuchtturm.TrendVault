//
//  TrendVaultApp.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

@main
struct TrendVaultApp: App {

    @State private var navigationStore = NavigationStore()
    @State private var mockStore = MockStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationStore)
                .environment(mockStore)
        }
    }
}
