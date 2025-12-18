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

    struct Board: Identifiable, Hashable {
        let id: UUID
        var title: String
    }

    var selection: Selection = .inbox

    // Placeholder für Chunk 2
    var boards: [Board] = [
        .init(id: UUID(), title: "Brand"),
        .init(id: UUID(), title: "Campaigns"),
        .init(id: UUID(), title: "UI Patterns")
    ]

    init() {}
}
