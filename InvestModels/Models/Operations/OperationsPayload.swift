//
//  OperationsPayload.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation

public struct OperationsPayload : Decodable {
    public var operations : [Operation] = []

    public enum CodingKeys: String, CodingKey {
        case operations
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        operations = try values.decodeIfPresent(forKey: .operations) ?? []
    }

}
