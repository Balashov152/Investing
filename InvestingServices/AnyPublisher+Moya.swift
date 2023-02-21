//
//  Subscribers+.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import Foundation
import Moya
import CombineMoya

public extension Subscribers.Completion where Failure: Error {
    var error: Error? {
        guard case let .failure(error) = self else {
            return nil
        }

        return error
    }
}

public extension AnyPublisher where Output == Response, Failure == MoyaError {
    /// Maps received data at key path into a Decodable object. If the conversion fails, the signal errors.
    func map<D: Decodable>(_ type: D.Type,
                           at key: APIBaseResponseKey,
                           using decoder: JSONDecoder) -> AnyPublisher<D, MoyaError>
    {
        map(type, atKeyPath: key.rawValue, using: decoder)
    }
}

public enum APIBaseResponseKey: String {
    case accounts, operations, instruments, candles
}

public extension Publisher {
    func receive(queue: DispatchQueue) -> Publishers.ReceiveOn<Self, DispatchQueue> {
        receive(on: queue)
    }
}
