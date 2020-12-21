//
//  OperationsPayload.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation


struct OperationsPayload : Decodable {
    var operations : [Operation] = []

    enum CodingKeys: String, CodingKey {
        case operations
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        operations = try values.decodeIfPresent(forKey: .operations) ?? []
    }

}
