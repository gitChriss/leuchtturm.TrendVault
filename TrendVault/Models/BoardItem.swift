//
//  BoardItem.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import Foundation
import SwiftData

@Model
final class BoardItem {

    @Attribute(.unique)
    var id: UUID

    var boardID: UUID
    var itemID: UUID

    var position: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        boardID: UUID,
        itemID: UUID,
        position: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.boardID = boardID
        self.itemID = itemID
        self.position = position
        self.createdAt = createdAt
    }
}
