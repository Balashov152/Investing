//
//  CalculatorManager.swift
//  Investing
//
//  Created by Sergey Balashov on 08.04.2022.
//

import Foundation
import InvestModels
import InvestingStorage

struct CalculatorManager {
    private let realmStorage: RealmStoraging

    init(realmStorage: RealmStoraging) {
        self.realmStorage = realmStorage
    }

    func calculateResult(on figi: String, in account: BrokerAccount) -> (result: MoneyAmount, average: MoneyAmount?)? {
        guard let instrument = realmStorage.share(figi: figi) else {
            return nil
        }

        let instrumentInProfile = account.portfolio?.positions.first(where: { $0.figi == figi })
        let operations = account.operations.filter { $0.figi == figi }
        let allOperations = operations.filter { $0.currency == instrument.currency }
        let operationWithOtherCurrency = operations.filter { $0.currency != instrument.currency }

        operationWithOtherCurrency.forEach { operation in
            print("Wrong currency operation", operation.type as Any)
        }

        var resultAmount: Double = allOperations.reduce(0) { result, operation in
            result + (operation.payment?.price ?? 0)
        }

        let average = average(
            for: instrumentInProfile,
            currency: instrument.currency,
            resultAmount: &resultAmount
        )

        return (result: MoneyAmount(currency: instrument.currency, value: resultAmount),
                average: average)
    }

    func average(
        for instrumentInProfile: PortfolioPosition?,
        currency: Price.Currency,
        resultAmount: inout Double
    ) -> MoneyAmount? {
        guard let quantity = instrumentInProfile?.quantity,
              let positionPrice = instrumentInProfile?.inPortfolioPrice else {
            return nil
        }

        resultAmount += positionPrice

        let averageAmount: Double = {
            if resultAmount > 0 {
                /// If we have positive result just show which price will be in zero
                return (positionPrice - resultAmount) / quantity.price
            } else {
                /// If we have negative result show which price should be to exit in zero
                return (abs(resultAmount) + positionPrice) / quantity.price
            }
        }()

        return MoneyAmount(currency: currency, value: averageAmount)
    }
}
