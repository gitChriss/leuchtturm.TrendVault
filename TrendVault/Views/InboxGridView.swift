//
//  InboxGridView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct InboxGridView: View {

    let items: [TrendItem]
    let searchText: String
    let zoomLevel: ZoomLevel

    @State private var selection: Set<UUID> = []

    private var filteredItems: [TrendItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard q.isEmpty == false else { return items }

        return items.filter { item in
            if item.tags.contains(where: { $0.lowercased().contains(q) }) { return true }
            if (item.source ?? "").lowercased().contains(q) { return true }
            if (item.note ?? "").lowercased().contains(q) { return true }
            if (item.ocrText ?? "").lowercased().contains(q) { return true }
            return false
        }
    }

    var body: some View {
        if filteredItems.isEmpty {
            emptyState
        } else {
            grid
        }
    }

    private var grid: some View {
        let columns = [GridItem(.adaptive(minimum: zoomLevel.tileWidth), spacing: zoomLevel.spacing)]

        return ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: zoomLevel.spacing) {
                ForEach(filteredItems) { item in
                    InboxTileView(
                        item: item,
                        zoomLevel: zoomLevel,
                        isSelected: selection.contains(item.id)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .onTapGesture {
                        handleTap(on: item.id)
                    }
                    .contextMenu {
                        Button(selection.contains(item.id) ? "Unselect" : "Select") {
                            toggleSelection(id: item.id)
                        }
                        Button("Select All") {
                            selection = Set(filteredItems.map { $0.id })
                        }
                        if selection.isEmpty == false {
                            Button("Clear Selection") {
                                selection.removeAll()
                            }
                        }
                    }
                }
            }
            .padding(zoomLevel.spacing)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("Inbox")
                .font(.title2)
                .fontWeight(.semibold)

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Noch keine Items. SeedData sollte hier gleich sichtbar sein.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Keine Treffer für deine Suche.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func handleTap(on id: UUID) {
        let flags = ModifierFlags.current()

        if flags.contains(.command) {
            toggleSelection(id: id)
            return
        }

        selection = [id]
    }

    private func toggleSelection(id: UUID) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }
}
