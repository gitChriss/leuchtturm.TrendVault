//
//  InboxTileView.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import SwiftUI

struct InboxTileView: View {

    let item: TrendItem
    let zoomLevel: ZoomLevel
    let isSelected: Bool

    @State private var image: NSImage?

    var body: some View {
        ZStack {
            tileBackground

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: zoomLevel.tileWidth, height: zoomLevel.tileHeight)
                    .clipped()
            } else {
                placeholder
            }

            if isSelected {
                selectionOverlay
            }
        }
        .frame(width: zoomLevel.tileWidth, height: zoomLevel.tileHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            loadThumbnailIfNeeded()
        }
    }

    private var tileBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(nsColor: .controlBackgroundColor))
    }

    private var placeholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.secondary)

            if item.tags.isEmpty == false && zoomLevel != .small {
                Text(item.tags.prefix(2).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 10)
            }
        }
        .frame(width: zoomLevel.tileWidth, height: zoomLevel.tileHeight)
    }

    private var selectionOverlay: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .strokeBorder(Color.accentColor, lineWidth: 3)
            .padding(1)
    }

    private func loadThumbnailIfNeeded() {
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
