//
//  PositionsPayload.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation

struct PositionsPayload : Decodable {
    var positions : [Position] = []

    enum CodingKeys: String, CodingKey {
        case positions = "positions"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        positions = try values.decodeIfPresent(forKey: .positions, default: [])
    }

}
