//
//  InvestingServicesFactory.swift
//  InvestingServices
//
//  Created by Sergey Balashov on 14.02.2023.
//

import Foundation

public struct InvestingServicesFactory {
    public func accountService() -> AccountService {
        AccountService()
    }
}
