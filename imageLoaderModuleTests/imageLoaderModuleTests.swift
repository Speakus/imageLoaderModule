//
//  imageLoaderModuleTests.swift
//  imageLoaderModuleTests
//
//  Created by Maxim Nikolaevich on 14.08.2022.
//

import XCTest
@testable import imageLoaderModule

final class imageLoaderModuleTests: XCTestCase {
    private let fakeUrl = URL(string: "fake:url")!
    private let goodImage: UIImage = {
        let img = UIImage(systemName: "house")!
        let imgData = img.pngData()!
        // this image will not change when converting to png and back to image.
        return UIImage(data: imgData)!
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

// MARK: - tests
extension imageLoaderModuleTests {
    func testImageCache() {
        let imgCache = ImageCache()
        let testData = Data("testData".utf8)
        let testKey = "testKey"
        XCTAssertEqual(nil, imgCache.getFromCache(testKey))
        imgCache.saveToCache(testKey, data: testData)
        XCTAssertEqual(testData,imgCache.getFromCache(testKey))
    }

    func testImageLoaderWithBadData() {
        let expectation = expectation(description: #function)
        let fakeData = Data("fakeData".utf8)
        let imgLoader = ImageLoader.init(with: FakeCache()) { url in
            return .success(fakeData)
        }

        imgLoader.loadImage(url: fakeUrl) { result in
            switch result {
                case let .failure(error):
                    guard let error = error as? ImgLoaderError else {
                        XCTFail(error.localizedDescription)
                        return
                    }
                    XCTAssertEqual(error, ImgLoaderError.badUrlData)
                    expectation.fulfill()
                case .success:
                    XCTFail()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testImageLoaderWithGoodData() {
        let expectation = expectation(description: #function)
        let expectedImg = goodImage
        let imgData = expectedImg.pngData()!
        let imgLoader = ImageLoader(with: FakeCache()) { url in
            return .success(imgData)
        }

        imgLoader.loadImage(url: fakeUrl) { result in
            switch result {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                case let .success(image):
                    XCTAssertEqual(image.pngData(), imgData)
                    expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testImageLoaderCache() {
        let expectation = expectation(description: #function)
        let expectedImg = goodImage
        let imgData = expectedImg.pngData()!
        var isLoadedOnce = false
        let imgLoader = ImageLoader(with: ImageCache()) { url in
            let result: Result<Data, Error>
            result = isLoadedOnce ? .failure(ImgLoaderError.loading) : .success(imgData)
            isLoadedOnce = true
            return result
        }

        imgLoader.loadImage(url: fakeUrl) { result in
            switch result {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                case let .success(image):
                    XCTAssertEqual(image.pngData(), imgData)
                    imgLoader.loadImage(url: self.fakeUrl) { result in
                        switch result {
                            case let .failure(error):
                                XCTFail(error.localizedDescription)
                            case let .success(image):
                                XCTAssertEqual(image.pngData(), imgData)
                                expectation.fulfill()
                        }
                    }
            }
        }

        wait(for: [expectation], timeout: 1)
    }
}

private class FakeCache: ImageCacheProtocol {
    func getFromCache(_ key: String) -> Data? { return nil }
    func saveToCache(_ key: String, data: Data) {}
}
