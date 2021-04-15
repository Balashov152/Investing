//
//  AnyPublisher+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import Foundation

extension AnyPublisher {
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        map { _ in () }.eraseToAnyPublisher()
    }
    
    func unwrap<T>() -> AnyPublisher<T, Failure> where Output == T? {
        filter { $0 != nil }.map { $0! }.eraseToAnyPublisher()
    }
}
