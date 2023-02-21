//
//  Decoder+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Foundation

public extension JSONDecoder {
    static var standart: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        return decoder
    }
}

public extension JSONEncoder {
    static var standart: JSONEncoder {
        let decoder = JSONEncoder()
        decoder.dateEncodingStrategy = .iso8601
        return decoder
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    static let customISO8601 = custom { decoder in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601withFractionalSeconds.date(from: string) ?? Formatter.iso8601.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

public extension Formatter {
    static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
