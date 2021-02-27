//
//  PayInViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation
import InvestModels

extension PayInViewModel {
    struct Section: Hashable, Identifiable {
        let rows: [Row]

        var header: String {
            if let row = rows.first?.date {
                return DateFormatter.format("MMMM yyyy")
                    .string(from: row).capitalized
            }
            return "no rows"
        }

        var result: MoneyAmount? {
            rows.map { $0.money }.moneySum
        }
    }

    struct Row: Hashable, Identifiable {
        let date: Date
        let money: MoneyAmount

        var localizedDate: String {
            DateFormatter.format("dd MMMM").string(from: date)
        }
    }
}

class PayInViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var sections: [Section] = []

    var convertCurrency: Currency {
        env.settings.currency ?? .RUB
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map {
                let onlyPay = $0.filter(types: [.PayIn, .PayOut])
                let grouped = Dictionary(grouping: onlyPay) { (element) -> Date in
                    Calendar.current.date(from: DateComponents(year: element.date.year,
                                                               month: element.date.month))!
                }
                return grouped.keys.sorted(by: >).compactMap { (date) -> Section? in
                    guard let values = grouped[date] else { return nil }
                    return Section(rows: values.map { [unowned self] value in
                        Row(date: value.date,
                            money: value.convertPayment(to: convertCurrency))
                    })
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))
    }
}
