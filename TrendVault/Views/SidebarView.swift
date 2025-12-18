//
//  SidebarView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct SidebarView: View {

    @Environment(NavigationStore.self) private var nav

    private var selectionBinding: Binding<NavigationStore.Selection?> {
        Binding(
            get: { nav.selection },
            set: { newValue in
                guard let newValue else { return }
                nav.selection = newValue
            }
        )
    }

    var body: some View {
        List(selection: selectionBinding) {

            Section("Library") {
                Label("Inbox", systemImage: "tray.full")
                    .tag(NavigationStore.Selection.inbox)
            }

            Section("Boards") {
                ForEach(nav.boards) { board in
                    Label(board.title, systemImage: "square.grid.2x2")
                        .tag(NavigationStore.Selection.board(board.id))
                }
            }

            Section("Other") {
                Label("Saved Searches", systemImage: "bookmark")
                    .tag(NavigationStore.Selection.savedSearches)

                Label("Settings", systemImage: "gearshape")
                    .tag(NavigationStore.Selection.settings)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("TrendVault")
    }
}

#Preview {
    SidebarView()
        .environment(NavigationStore())
}
