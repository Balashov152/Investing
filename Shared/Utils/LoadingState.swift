//
//  LoadingState.swift
//  Investing
//
//  Created by Sergey Balashov on 13.01.2021.
//

import Foundation

enum LoadingState<Object>: Equatable {
    static func == (lhs: LoadingState<Object>, rhs: LoadingState<Object>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.failure, .failure):
            return true
        default: return false
        }
    }

    case loading

    case loaded(object: Object)
    case failure(error: LoadingError)

    var object: Object? {
        guard case let .loaded(object) = self else {
            return nil
        }
        return object
    }

    var error: LoadingError? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}
