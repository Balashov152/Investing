//
//  LoadingError.swift
//  Investing
//
//  Created by Sergey Balashov on 13.01.2021.
//

import Foundation

enum LoadingError: Error, LocalizedError {
    case error(code: Int)

    var errorDescription: String? {
        switch self {
        case let .error(code):
            return "Status code" + code.string
        }
    }
}
