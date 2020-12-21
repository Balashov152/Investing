//
//  Decoder+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Foundation
extension KeyedDecodingContainer where K : CodingKey {
    public func decodeIfPresent<T>(forKey key: Self.Key) throws -> T? where T : Decodable {
        try self.decodeIfPresent(T.self, forKey: key)
    }
    
    public func decodeIfPresent<T>(forKey key: Self.Key, default: T) throws -> T where T : Decodable {
        try self.decodeIfPresent(T.self, forKey: key) ?? `default`
    }
}
