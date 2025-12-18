//
//  SidebarView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct SidebarView: View {

    @Environment(NavigationStore.self) private var nav

    @State private var isCreateBoardPresented: Bool = false
    @State private var createBoardTitle: String = ""

    @State private var renameBoardID: UUID? = nil
    @State private var renameBoardTitle: String = ""

    @State private var deleteBoardID: UUID? = nil
    @State private var isDeleteConfirmPresented: Bool = false

    private var selectionBinding: Binding<NavigationStore.Selection?> {
        Binding(
            get: { nav.selection },
            set: { newValue in
                guard let newValue else { return }
                nav.selection = newValue
            }
        )
    }

    private var sortedBoards: [Board] {
        nav.boards.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        List(selection: selectionBinding) {

            Section("Library") {
                Label("Inbox", systemImage: "tray.full")
                    .tag(NavigationStore.Selection.inbox)
            }

            Section("Boards") {
                ForEach(sortedBoards) { board in
                    Label(board.title, systemImage: "square.grid.2x2")
                        .tag(NavigationStore.Selection.board(board.id))
                        .contextMenu {
                            Button("Rename") {
                                renameBoardID = board.id
                                renameBoardTitle = board.title
                            }

                            Divider()

                            Button("Delete", role: .destructive) {
                                deleteBoardID = board.id
                                isDeleteConfirmPresented = true
                            }
                        }
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    createBoardTitle = ""
                    isCreateBoardPresented = true
                } label: {
                    Image(systemName: "plus")
                }
                .help("Create Board")
            }
        }
        .alert("Create Board", isPresented: $isCreateBoardPresented) {
            TextField("Title", text: $createBoardTitle)

            Button("Create") {
                let title = createBoardTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard title.isEmpty == false else { return }

                let board = nav.store.createBoard(title: title)
                nav.selection = .board(board.id)
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Give your board a name.")
        }
        .alert("Rename Board", isPresented: Binding(
            get: { renameBoardID != nil },
            set: { newValue in
                if newValue == false { renameBoardID = nil }
            }
        )) {
            TextField("Title", text: $renameBoardTitle)

            Button("Save") {
                guard let id = renameBoardID else { return }
                let title = renameBoardTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard title.isEmpty == false else { return }

                nav.store.renameBoard(boardID: id, title: title)
                renameBoardID = nil
            }

            Button("Cancel", role: .cancel) {
                renameBoardID = nil
            }
        } message: {
            Text("Update the title of this board.")
        }
        .confirmationDialog(
            "Delete Board?",
            isPresented: $isDeleteConfirmPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let id = deleteBoardID else { return }

                nav.store.deleteBoard(boardID: id)

                if case .board(let selectedID) = nav.selection, selectedID == id {
                    nav.selection = .inbox
                }

                deleteBoardID = nil
            }

            Button("Cancel", role: .cancel) {
                deleteBoardID = nil
            }
        } message: {
            Text("This removes the board. Items stay in your library.")
        }
    }
}

#Preview {
    SidebarView()
        .environment(NavigationStore())
}
