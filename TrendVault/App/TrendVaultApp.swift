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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationStore)
        }
    }
}
