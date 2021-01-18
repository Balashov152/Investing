//
//  ImageCache.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import SwiftUI
import UIKit

protocol ImageCache {
    subscript(_: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    static let shared = TemporaryImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    private init() {}

    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

// struct ImageCacheKey: EnvironmentKey {
//    static let defaultValue: ImageCache = TemporaryImageCache()
// }
//
// extension EnvironmentValues {
//    var imageCache: ImageCache {
//        get { self[ImageCacheKey.self] }
//        set { self[ImageCacheKey.self] = newValue }
//    }
// }