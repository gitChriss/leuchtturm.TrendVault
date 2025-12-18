//
//  ThumbnailCache.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import AppKit

final class ThumbnailCache {

    static let shared = ThumbnailCache()

    private let cache = NSCache<NSUUID, NSImage>()

    private init() {
        cache.countLimit = 2000
    }

    func image(for id: UUID) -> NSImage? {
        cache.object(forKey: id as NSUUID)
    }

    func setImage(_ image: NSImage, for id: UUID) {
        cache.setObject(image, forKey: id as NSUUID)
    }
}
