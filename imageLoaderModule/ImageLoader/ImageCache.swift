//
//  ImageCache.swift
//  tmp
//
//  Created by Maxim Nikolaevich on 08.08.2022.
//

import Foundation

internal protocol ImageCacheProtocol {
    func getFromCache(_ key: String) -> Data?
    func saveToCache(_ key: String, data: Data)
}

final internal class ImageCache {
    internal init() { }
    internal static let shared = ImageCache()

    private var memoryCache = [String: Data]()
    private static let cacheQueue = DispatchQueue(label: "cacheQueue")
}

extension ImageCache: ImageCacheProtocol {
    internal func getFromCache(_ key: String) -> Data? {
        ImageCache.cacheQueue.sync {
            return memoryCache[key]
        }
    }

    internal func saveToCache(_ key: String, data: Data) {
        ImageCache.cacheQueue.sync {
            memoryCache[key] = data
        }
    }
}
