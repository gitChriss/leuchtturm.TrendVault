//
//  Board.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import Foundation
import SwiftData

@Model
final class Board {

    @Attribute(.unique)
    var id: UUID

    var title: String

    var createdAt: Date
    var modifiedAt: Date

    var sortOrder: Int

    var color: String?
    var icon: String?
    var coverItemID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        sortOrder: Int = 0,
        color: String? = nil,
        icon: String? = nil,
        coverItemID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.sortOrder = sortOrder
        self.color = color
        self.icon = icon
        self.coverItemID = coverItemID
    }
}
