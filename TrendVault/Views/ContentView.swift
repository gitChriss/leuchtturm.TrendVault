//
//  ContentView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct ContentView: View {

    @Environment(NavigationStore.self) private var nav
    @Environment(MockStore.self) private var store

    @State private var searchText: String = ""
    @State private var zoomLevel: ZoomLevel = .medium

    @State private var selectedItemID: UUID? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            detailContent
                .navigationTitle(detailTitle)
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search")
        .toolbar {
            ToolbarItemGroup {
                filterMenu
                zoomControl
            }
        }
        .onChange(of: nav.selection) { _, _ in
            selectedItemID = nil
        }
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailContent: some View {
        switch nav.selection {
        case .inbox:
            inboxDetail

        case .board(let id):
            let boardTitle = nav.boards.first(where: { $0.id == id })?.title ?? "Board"
            PlaceholderDetailView(
                title: boardTitle,
                subtitle: "Board View kommt in Chunk 7"
            )

        case .savedSearches:
            PlaceholderDetailView(
                title: "Saved Searches",
                subtitle: "Placeholder"
            )

        case .settings:
            PlaceholderDetailView(
                title: "Settings",
                subtitle: "Placeholder"
            )
        }
    }

    private var inboxDetail: some View {
        HStack(spacing: 0) {
            InboxGridView(
                items: store.items,
                searchText: searchText,
                zoomLevel: zoomLevel,
                selectedItemID: $selectedItemID
            )

            Divider()

            Group {
                if let selectedItemID,
                   let item = store.items.first(where: { $0.id == selectedItemID }) {
                    DetailView(item: item, selectedItemID: $selectedItemID)
                        .frame(minWidth: 360)
                } else {
                    PlaceholderDetailView(
                        title: "Detail",
                        subtitle: "Wähle ein Item aus, um Metadaten zu bearbeiten."
                    )
                    .frame(minWidth: 360)
                }
            }
        }
    }

    private var detailTitle: String {
        switch nav.selection {
        case .inbox:
            return "Inbox"
        case .board(let id):
            return nav.boards.first(where: { $0.id == id })?.title ?? "Board"
        case .savedSearches:
            return "Saved Searches"
        case .settings:
            return "Settings"
        }
    }

    // MARK: - Toolbar

    private var filterMenu: some View {
        Menu {
            Text("Filters (placeholder)")
            Divider()
            Button("Tags") { }
                .disabled(true)
            Button("Date") { }
                .disabled(true)
            Button("Source") { }
                .disabled(true)
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
        .help("Filter (placeholder)")
    }

    private var zoomControl: some View {
        Picker("Zoom", selection: $zoomLevel) {
            ForEach(ZoomLevel.allCases) { level in
                Image(systemName: level.systemImageName)
                    .tag(level)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 160)
        .help("Zoom")
    }
}

// MARK: - Supporting Views

private struct PlaceholderDetailView: View {

    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Zoom

enum ZoomLevel: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .small: return "square.grid.3x3"
        case .medium: return "square.grid.2x2"
        case .large: return "rectangle.grid.1x2"
        }
    }

    var tileWidth: CGFloat {
        switch self {
        case .small: return 120
        case .medium: return 180
        case .large: return 260
        }
    }

    var tileHeight: CGFloat {
        switch self {
        case .small: return 120
        case .medium: return 180
        case .large: return 220
        }
    }

    var spacing: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }
}

#Preview {
    ContentView()
        .environment(NavigationStore())
        .environment(MockStore())
}
