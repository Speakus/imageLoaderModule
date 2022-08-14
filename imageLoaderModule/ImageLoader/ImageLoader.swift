//
//  ImageLoader.swift
//  tmp
//
//  Created by Maxim Nikolaevich on 08.08.2022.
//

import Foundation
import UIKit

final internal class ImageLoader {
    internal typealias DataLoaderBlock = (_ url: URL) -> Result<Data, Error>
    internal init(with cache: ImageCacheProtocol, dataLoadBlock: @escaping DataLoaderBlock) {
        self.cache = cache
        self.dataLoadBlock = dataLoadBlock
    }

    private let cache: ImageCacheProtocol
    private let dataLoadBlock: DataLoaderBlock

    internal static let shared = ImageLoader(with: ImageCache.shared) { url in
        do {
            let data = try Data(contentsOf: url)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }

    typealias CompletionBlock = (_ result: Result<UIImage, Error>) -> Void

    internal func loadImage(url: URL, completion: @escaping CompletionBlock) {
        let urlString = url.absoluteString
        DispatchQueue.global().async {
            if let cachedData = self.cache.getFromCache(urlString) {
                self.make(from: cachedData, errorForFail: .badCache, completion: completion)
                return
            }

            let result = self.dataLoadBlock(url)
            switch result {
                case let .failure(error):
                    completion(.failure(error))
                case let .success(data):
                    self.cache.saveToCache(urlString, data: data)
                    self.make(from: data, errorForFail: .badUrlData, completion: completion)
            }
        }
    }

    private func make(from data: Data, errorForFail: ImgLoaderError, completion: CompletionBlock) {
        guard let img = UIImage.init(data: data) else {
            completion(.failure(errorForFail))
            return
        }
        completion(.success(img))
    }
}
