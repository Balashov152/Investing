//
//  OperationState.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation

enum OperationState: String, Encodable, Hashable {
    case unspecified = "OPERATION_STATE_UNSPECIFIED"
    case executed = "OPERATION_STATE_EXECUTED"
    case canceled = "OPERATION_STATE_CANCELED"
}
