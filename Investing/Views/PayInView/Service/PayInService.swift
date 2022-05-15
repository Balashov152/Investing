//
//  PayInService.swift
//  Investing
//
//  Created by Sergey Balashov on 29.04.2021.
//

import Foundation
import InvestModels

struct PayInService {
    let env: Environment
    var currency: Currency {
        env.settings.currency ?? .RUB
    }

    func payInOut(operations: [Operation]) -> [Year] {
        let onlyPay = operations.filter(types: [.PayIn, .PayOut])
        let grouped = Dictionary(grouping: onlyPay) { element -> Date in
            Calendar.current.date(from: DateComponents(year: element.date.year,
                                                       month: element.date.month)) ?? Date()
        }

        let years = Dictionary(grouping: onlyPay) { $0.date.year }
        return years.keys.sorted(by: >).map { year -> Year in
            Year(year: year, months: months(year: year, grouped: grouped))
        }
    }

    private func months(year: Int, grouped: [Date: [Operation]]) -> [Month] {
        grouped
            .filter { $0.key.year == year }.keys
            .sorted(by: >).compactMap { date -> Month? in
                guard let values = grouped[date] else { return nil }
                return Month(operations: values.map { value in
                    PayOperation(date: value.date,
                                 money: value.convertPayment(to: currency))
                })
            }
    }
}

extension PayInService {
    struct Year: Hashable, Identifiable {
        let year: Int
        let months: [Month]

        var result: MoneyAmount? {
            months.compactMap { $0.result }.moneySum
        }
    }

    struct Month: Hashable, Identifiable {
        let operations: [PayOperation]

        var result: MoneyAmount? {
            operations.map { $0.money }.moneySum
        }
    }

    struct PayOperation: Hashable, Identifiable {
        let date: Date
        let money: MoneyAmount
    }
}
