//
//  AnyPublisher+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import Foundation

public extension AnyPublisher {
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        map { _ in () }.eraseToAnyPublisher()
    }

    func unwrap<T>() -> AnyPublisher<T, Failure> where Output == T? {
        compactMap { $0 }.eraseToAnyPublisher()
    }
}
