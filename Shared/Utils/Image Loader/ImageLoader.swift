//
//  ImageLoader.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: CancebleObject, ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private var cache: ImageCache?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    private(set) var isLoading = false

    init(url: URL, cache: ImageCache) {
            self.url = url
            self.cache = cache
        }

    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading else { return }
        
        if let image = cache?[url] {
                    self.image = image
                    return
                }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: Self.imageProcessingQueue)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                                      receiveOutput: { [weak self] in self?.cache($0) },
                                      receiveCompletion: { [weak self] _ in self?.onFinish() },
                                      receiveCancel: { [weak self] in self?.onFinish() })
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
            .store(in: &cancellables)
    }

    func cancel() {
        cancellables.forEach { $0.cancel() }
    }
    
    private func onStart() {
            isLoading = true
        }
        
        private func onFinish() {
            isLoading = false
        }
    
    private func cache(_ image: UIImage?) {
            image.map { cache?[url] = $0 }
        }
}
