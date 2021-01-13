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
        case let (.loaded(obj1), .loaded(obj2)):
            return true
        case let (.failure(err1), .failure(err2)):
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
