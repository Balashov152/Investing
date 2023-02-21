//
//  ContentState.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 18.01.2022.
//

import Foundation

public enum ContentState: Equatable {
    case loading
    case content
    case failure(error: LoadingError)

    public var error: LoadingError? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}
