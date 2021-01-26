//
//  CommonViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Combine
import Foundation
import SwiftUI

open class CancebleObject {
    public var cancellables = Set<AnyCancellable>()

    public init() {
        debugPrint("init", type(of: self))
    }

    deinit {
        debugPrint("deinit", type(of: self))
    }
}

open class EnvironmentCancebleObject: CancebleObject {
    internal var env: Environment

    internal init(env: Environment = .current) {
        self.env = env

        super.init()

        bindings()
    }

    open func bindings() {}
}
