//
//  NavigationStore.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import Foundation
import SwiftUI

@Observable
final class NavigationStore {

    enum Selection: Hashable {
        case inbox
        case board(UUID)
        case savedSearches
        case settings
    }

    var selection: Selection = .inbox

    // Mock Store (Chunk 4)
    let store: MockStore

    // Convenience für bestehende UI (Sidebar/Title)
    var boards: [Board] { store.boards }

    init(store: MockStore = MockStore()) {
        self.store = store
    }
}
