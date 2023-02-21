//
//  InstrumentTypeV2.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation

public enum InstrumentTypeV2: String, Codable, Equatable, Hashable {
    case share, currency, bond, etf

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        if rawValue.isEmpty {
            self = .share
        } else {
            self.init(rawValue: rawValue)!
        }
    }
}
