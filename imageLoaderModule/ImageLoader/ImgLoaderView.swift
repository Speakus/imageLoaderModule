//
//  ImgLoaderView.swift
//  tmp
//
//  Created by Maxim Nikolaevich on 08.08.2022.
//

import UIKit

open class ImgLoaderView: UIImageView {
    public final func setImg(from url: URL, completion: @escaping (Error?) -> Void) {
            ImageLoader.shared.loadImage(url: url) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                        case let .failure(error):
                            completion(error)
                        case let .success(img):
                            self?.image = img
                    }
                }
            }
    }
}
