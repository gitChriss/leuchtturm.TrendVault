//
//  DetailView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct DetailView: View {

    @Environment(MockStore.self) private var store

    let item: TrendItem
    @Binding var selectedItemID: UUID?

    @State private var image: NSImage?

    @State private var tagsText: String = ""
    @State private var sourceText: String = ""
    @State private var noteText: String = ""

    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    preview

                    metadataForm

                    Spacer(minLength: 0)
                }
                .padding(16)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            hydrateFields()
            loadPreviewIfNeeded()
        }
        .onChange(of: item.id) { _, _ in
            hydrateFields()
            image = nil
            loadPreviewIfNeeded()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Detail")
                    .font(.headline)

                Text("Created \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .help("Löscht das Item global, auch aus allen Boards.")
        }
        .padding(16)
        .confirmationDialog(
            "Item löschen",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                store.deleteItem(itemID: item.id)
                selectedItemID = nil
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Dieses Item wird überall entfernt, auch aus allen Boards.")
        }
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preview")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))

                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("No preview")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 320)
        }
    }

    private var metadataForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Metadata")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                fieldLabel("Tags")
                TextField("comma separated", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        applyTags()
                    }

                fieldLabel("Source")
                TextField("optional", text: $sourceText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        applySource()
                    }

                fieldLabel("Note")
                TextEditor(text: $noteText)
                    .font(.body)
                    .frame(minHeight: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color(nsColor: .separatorColor))
                    )

                HStack {
                    Spacer()

                    Button("Save") {
                        applyAll()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private func hydrateFields() {
        tagsText = item.tags.joined(separator: ", ")
        sourceText = item.source ?? ""
        noteText = item.note ?? ""
    }

    private func applyAll() {
        applyTags()
        applySource()
        applyNote()
    }

    private func applyTags() {
        let parsed = tagsText
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        store.setTags(itemID: item.id, tags: parsed)
    }

    private func applySource() {
        let trimmed = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        store.setSource(itemID: item.id, source: trimmed.isEmpty ? nil : trimmed)
    }

    private func applyNote() {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        store.setNote(itemID: item.id, note: trimmed.isEmpty ? nil : trimmed)
    }

    private func loadPreviewIfNeeded() {
        if let cached = ThumbnailCache.shared.image(for: item.id) {
            image = cached
            return
        }

        guard item.thumbnailData.isEmpty == false else { return }
        guard let decoded = NSImage(data: item.thumbnailData) else { return }

        ThumbnailCache.shared.setImage(decoded, for: item.id)
        image = decoded
    }
}
