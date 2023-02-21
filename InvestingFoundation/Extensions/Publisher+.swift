//
//  Publisher+.swift
//  Investing
//
//  Created by Sergey Balashov on 04.04.2022.
//

import Combine

public extension Publisher {
    /// Subscribes to current publisher without handling events
    func sink() -> AnyCancellable {
        return sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }

    /// `receiveValue` clouser from default `sink` method
    func receiveValue(_ receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }

    /// `receiveCompletion` clouser from default `sink` method
    func receiveCompletion(_ receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: receiveCompletion, receiveValue: { _ in })
    }

    /// Transforms any received value to Void
    func mapVoid() -> Publishers.Map<Self, Void> {
        map { _ in }
    }
}

public extension Publisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty().eraseToAnyPublisher()
    }
}
