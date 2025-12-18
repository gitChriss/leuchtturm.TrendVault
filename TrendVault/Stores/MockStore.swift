//
//  MockStore.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import Foundation
import SwiftUI

@Observable
final class MockStore {

    // MARK: - Data (in-memory)

    private(set) var items: [TrendItem]
    private(set) var boards: [Board]
    private(set) var boardItems: [BoardItem]

    // MARK: - Init

    init(
        items: [TrendItem] = SeedData.makeItems(),
        boards: [Board] = SeedData.makeBoards()
    ) {
        self.items = items
        self.boards = boards
        self.boardItems = SeedData.makeBoardItems(boards: boards, items: items)
        normalizeBoardItemPositions()
    }

    // MARK: - Boards (CRUD)

    @discardableResult
    func createBoard(title: String) -> Board {
        let nextSortOrder = (boards.map { $0.sortOrder }.max() ?? -1) + 1
        let board = Board(title: title, sortOrder: nextSortOrder)
        boards.append(board)
        return board
    }

    func renameBoard(boardID: UUID, title: String) {
        guard let index = boards.firstIndex(where: { $0.id == boardID }) else { return }
        boards[index].title = title
        boards[index].modifiedAt = Date()
    }

    func deleteBoard(boardID: UUID) {
        boards.removeAll { $0.id == boardID }
        boardItems.removeAll { $0.boardID == boardID }
    }

    // MARK: - Items (CRUD)

    @discardableResult
    func createItem(
        tags: [String] = [],
        source: String? = nil,
        note: String? = nil,
        ocrText: String? = nil,
        thumbnailData: Data = Data(),
        imageAssetRef: String? = nil
    ) -> TrendItem {
        let now = Date()
        let item = TrendItem(
            createdAt: now,
            modifiedAt: now,
            tags: tags,
            source: source,
            note: note,
            ocrText: ocrText,
            thumbnailData: thumbnailData,
            imageAssetRef: imageAssetRef
        )
        items.insert(item, at: 0)
        return item
    }

    /// Setzt Felder gezielt. Parameter sind "no change", wenn nil.
    /// Willst du absichtlich auf nil setzen, nutze die expliziten Setter darunter.
    func updateItem(
        itemID: UUID,
        tags: [String]? = nil,
        source: String?? = nil,
        note: String?? = nil
    ) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }

        var didChange = false

        if let tags {
            items[index].tags = normalizeTags(tags)
            didChange = true
        }

        if let source {
            items[index].source = source
            didChange = true
        }

        if let note {
            items[index].note = note
            didChange = true
        }

        if didChange {
            items[index].modifiedAt = Date()
        }
    }

    func setTags(itemID: UUID, tags: [String]) {
        updateItem(itemID: itemID, tags: tags, source: nil, note: nil)
    }

    func addTags(itemID: UUID, tags: [String]) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        let merged = Array(Set(items[index].tags).union(tags))
        items[index].tags = normalizeTags(merged)
        items[index].modifiedAt = Date()
    }

    func removeTags(itemID: UUID, tags: [String]) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        let removeSet = Set(tags)
        items[index].tags = normalizeTags(items[index].tags.filter { removeSet.contains($0) == false })
        items[index].modifiedAt = Date()
    }

    func setSource(itemID: UUID, source: String?) {
        // Double-optional, damit "absichtlich nil setzen" möglich ist.
        updateItem(itemID: itemID, tags: nil, source: .some(source), note: nil)
    }

    func setNote(itemID: UUID, note: String?) {
        updateItem(itemID: itemID, tags: nil, source: nil, note: .some(note))
    }

    func deleteItem(itemID: UUID) {
        items.removeAll { $0.id == itemID }
        boardItems.removeAll { $0.itemID == itemID }
    }

    // MARK: - Board membership

    func isItemInBoard(boardID: UUID, itemID: UUID) -> Bool {
        boardItems.contains { $0.boardID == boardID && $0.itemID == itemID }
    }

    func itemsInBoard(boardID: UUID) -> [TrendItem] {
        let orderedJoins = boardItems
            .filter { $0.boardID == boardID }
            .sorted { $0.position < $1.position }

        let lookup = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })

        return orderedJoins.compactMap { lookup[$0.itemID] }
    }

    func addItemToBoard(boardID: UUID, itemID: UUID) {
        guard boards.contains(where: { $0.id == boardID }) else { return }
        guard items.contains(where: { $0.id == itemID }) else { return }
        guard isItemInBoard(boardID: boardID, itemID: itemID) == false else { return }

        let nextPosition = (boardItems
            .filter { $0.boardID == boardID }
            .map { $0.position }
            .max() ?? -1) + 1

        boardItems.append(
            BoardItem(
                boardID: boardID,
                itemID: itemID,
                position: nextPosition
            )
        )
    }

    func removeItemFromBoard(boardID: UUID, itemID: UUID) {
        boardItems.removeAll { $0.boardID == boardID && $0.itemID == itemID }
        normalizePositions(in: boardID)
    }

    func reorderItemsInBoard(boardID: UUID, orderedItemIDs: [UUID]) {
        let current = boardItems
            .filter { $0.boardID == boardID }
            .sorted { $0.position < $1.position }

        guard current.isEmpty == false else { return }

        var positionByItemID: [UUID: Int] = [:]
        for (index, itemID) in orderedItemIDs.enumerated() {
            positionByItemID[itemID] = index
        }

        // Fallback: Wenn orderedItemIDs unvollständig ist, hängen wir fehlende Items ans Ende.
        var nextFallback = (positionByItemID.values.max() ?? -1) + 1

        for join in current {
            if positionByItemID[join.itemID] == nil {
                positionByItemID[join.itemID] = nextFallback
                nextFallback += 1
            }
        }

        for i in boardItems.indices {
            guard boardItems[i].boardID == boardID else { continue }
            boardItems[i].position = positionByItemID[boardItems[i].itemID] ?? boardItems[i].position
        }

        normalizePositions(in: boardID)
    }

    /// Für späteres SwiftUI `onMove` im Board-Grid.
    func moveItemsInBoard(boardID: UUID, fromOffsets: IndexSet, toOffset: Int) {
        var ordered = boardItems
            .filter { $0.boardID == boardID }
            .sorted { $0.position < $1.position }
            .map { $0.itemID }

        ordered.move(fromOffsets: fromOffsets, toOffset: toOffset)
        reorderItemsInBoard(boardID: boardID, orderedItemIDs: ordered)
    }

    // MARK: - Helpers

    private func normalizeBoardItemPositions() {
        let boardIDs = Set(boardItems.map { $0.boardID })
        for boardID in boardIDs {
            normalizePositions(in: boardID)
        }
    }

    private func normalizePositions(in boardID: UUID) {
        let joins = boardItems
            .filter { $0.boardID == boardID }
            .sorted { $0.position < $1.position }

        var nextPosition = 0
        let idsInOrder = joins.map { $0.id }

        for joinID in idsInOrder {
            guard let idx = boardItems.firstIndex(where: { $0.id == joinID }) else { continue }
            boardItems[idx].position = nextPosition
            nextPosition += 1
        }
    }

    private func normalizeTags(_ tags: [String]) -> [String] {
        tags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .map { $0.lowercased() }
            .sorted()
    }
}
