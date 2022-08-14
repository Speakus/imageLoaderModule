//
//  ImageLoader.swift
//  tmp
//
//  Created by Maxim Nikolaevich on 08.08.2022.
//

import Foundation
import UIKit

final internal class ImageLoader {
    private init() { }

    internal static let shared = ImageLoader()
    typealias CompletionBlock = (_ result: Result<UIImage, Error>) -> Void

    internal func loadImage(url: URL, completion: @escaping CompletionBlock) {
        let urlString = url.absoluteString
        DispatchQueue.global().async {
            if let cachedData = ImageCache.shared.getFromCache(urlString) {
                self.make(from: cachedData, errorForFail: .badCache, completion: completion)
                return
            }

            do {
                let data = try Data(contentsOf: url)
                ImageCache.shared.saveToCache(urlString, data: data)
                self.make(from: data, errorForFail: .badUrlData, completion: completion)
            } catch {
                completion(.failure(error))
                return
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
