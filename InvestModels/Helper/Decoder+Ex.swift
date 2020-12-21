//
//  Decoder+Ex.swift
//  InvestModels
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation

public extension KeyedDecodingContainer where K : CodingKey {
    func decodeIfPresent<T>(forKey key: Self.Key) throws -> T? where T : Decodable {
        try self.decodeIfPresent(T.self, forKey: key)
    }
    
    func decodeIfPresent<T>(forKey key: Self.Key, default: T) throws -> T where T : Decodable {
        try self.decodeIfPresent(T.self, forKey: key) ?? `default`
    }
}
