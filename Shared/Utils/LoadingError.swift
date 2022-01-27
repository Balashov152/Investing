//
//  LoadingError.swift
//  Investing
//
//  Created by Sergey Balashov on 13.01.2021.
//

import Foundation

enum LoadingError: Error, LocalizedError, Equatable {
    case error(code: Int)
    case simpleError(string: String)

    var errorDescription: String? {
        switch self {
        case let .error(code):
            return "Status code" + code.string
        case let .simpleError(string):
            return string
        }
    }
}
