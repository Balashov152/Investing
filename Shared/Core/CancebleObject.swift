//
//  CancebleObject.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import Foundation

open class CancebleObject {
    public var cancellables: Set<AnyCancellable> = []

    public init() {
        debugPrint("init", type(of: self))
    }

    deinit {
        debugPrint("deinit", type(of: self))
    }
}
