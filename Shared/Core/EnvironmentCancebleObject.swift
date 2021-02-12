//
//  EnvironmentCancebleObject.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Combine
import Foundation

open class EnvironmentCancebleObject: CancebleObject {
    internal var env: Environment

    internal init(env: Environment = .current) {
        self.env = env

        super.init()

        bindings()
    }

    open func bindings() {}
}
