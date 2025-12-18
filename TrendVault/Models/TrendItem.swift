//
//  TrendItem.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import Foundation
import SwiftData

@Model
final class TrendItem {

    @Attribute(.unique)
    var id: UUID

    var createdAt: Date
    var modifiedAt: Date

    var tags: [String]

    var source: String?
    var note: String?
    var ocrText: String?

    var thumbnailData: Data
    var imageAssetRef: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        tags: [String] = [],
        source: String? = nil,
        note: String? = nil,
        ocrText: String? = nil,
        thumbnailData: Data = Data(),
        imageAssetRef: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.tags = tags
        self.source = source
        self.note = note
        self.ocrText = ocrText
        self.thumbnailData = thumbnailData
        self.imageAssetRef = imageAssetRef
    }
}
