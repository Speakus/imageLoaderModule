//
//  ImageCache.swift
//  tmp
//
//  Created by Maxim Nikolaevich on 08.08.2022.
//

import Foundation

final internal class ImageCache {
    private init() { }
    internal static let shared = ImageCache()

    private var memoryCache = [String: Data]()
    private static let cacheQueue = DispatchQueue(label: "cacheQueue")

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
