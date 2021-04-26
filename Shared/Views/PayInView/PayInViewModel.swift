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
        let year: Int
        let months: [Month]

        var result: MoneyAmount? {
            months.compactMap { $0.result }.moneySum
        }
    }

    struct Month: Hashable, Identifiable {
        let rows: [Row]

        var header: String {
            if let row = rows.first?.date {
                return DateFormatter.format("LLLL")
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

    var currency: Currency {
        env.settings.currency ?? .RUB
    }

    override func bindings() {
        super.bindings()
        env.api().operationsService.$operations
            .receive(on: DispatchQueue.global())
            .map { [unowned self] operations in
                let onlyPay = operations.filter(types: [.PayIn, .PayOut])
                let grouped = Dictionary(grouping: onlyPay) { (element) -> Date in
                    Calendar.current.date(from: DateComponents(year: element.date.year,
                                                               month: element.date.month))!
                }

                let years = Dictionary(grouping: onlyPay) { $0.date.year }
                return years.keys.sorted(by: >).map { year -> Section in
                    Section(year: year, months: months(year: year, grouped: grouped))
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)
    }

    private func months(year: Int, grouped: [Date: [Operation]]) -> [Month] {
        grouped
            .filter { $0.key.year == year }.keys
            .sorted(by: >).compactMap { (date) -> Month? in
                guard let values = grouped[date] else { return nil }
                return Month(rows: values.map { value in
                    Row(date: value.date,
                        money: value.convertPayment(to: currency))
                })
            }
    }

    public func load() {
        env.api().operationsService.getOperations(request: .init(env: env))
    }
}
