//
//  AnyPublisher+async.swift
//  Investing
//
//  Created by Sergey Balashov on 06.01.2023.
//

import Combine

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = first()
                .sink { completion in
                    if case let .failure(error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { output in
                    continuation.resume(returning: output)
                }
        }
    }
}
