//
//  PositionsPayload.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation

public struct PositionsPayload : Decodable {
    public var positions : [Position] = []

    public enum CodingKeys: String, CodingKey {
        case positions = "positions"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        positions = try values.decodeIfPresent(forKey: .positions, default: [])
    }
}
