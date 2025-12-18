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

    // Placeholder für Chunk 2 (jetzt mit Domain Model)
    var boards: [Board] = SeedData.makeBoards()

    init() {}
}
