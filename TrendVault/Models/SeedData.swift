//
//  SeedData.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import Foundation

enum SeedData {

    static func makeBoards() -> [Board] {
        [
            Board(title: "Brand", sortOrder: 0),
            Board(title: "Campaigns", sortOrder: 1),
            Board(title: "UI Patterns", sortOrder: 2)
        ]
    }

    static func makeItems(count: Int = 24) -> [TrendItem] {
        let tagPool: [String] = [
            "brand", "typography", "layout", "color",
            "ads", "landingpage", "cta", "copy",
            "ui", "pricing", "saas", "b2b"
        ]

        return (0..<max(0, count)).map { index in
            let created = Date().addingTimeInterval(TimeInterval(-index * 3600))
            let tags = pickTags(from: tagPool, minCount: 1, maxCount: 4)

            return TrendItem(
                createdAt: created,
                modifiedAt: created,
                tags: tags,
                source: "Seed",
                note: index.isMultiple(of: 5) ? "Sample note \(index)" : nil,
                ocrText: nil,
                thumbnailData: Data(),
                imageAssetRef: nil
            )
        }
    }

    static func makeBoardItems(boards: [Board], items: [TrendItem]) -> [BoardItem] {
        guard boards.isEmpty == false, items.isEmpty == false else { return [] }

        var result: [BoardItem] = []

        for (bIndex, board) in boards.enumerated() {
            let sliceStart = min(items.count, bIndex * 6)
            let sliceEnd = min(items.count, sliceStart + 10)
            let subset = Array(items[sliceStart..<sliceEnd])

            for (pos, item) in subset.enumerated() {
                result.append(
                    BoardItem(
                        boardID: board.id,
                        itemID: item.id,
                        position: pos
                    )
                )
            }
        }

        return result
    }

    // MARK: - Helpers

    private static func pickTags(from pool: [String], minCount: Int, maxCount: Int) -> [String] {
        guard pool.isEmpty == false else { return [] }

        let safeMin = Swift.max(0, minCount)
        let safeMax = Swift.max(safeMin, maxCount)
        let count = Int.random(in: safeMin...safeMax)

        return Array(pool.shuffled().prefix(count))
    }
}
