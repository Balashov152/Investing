//
//  PayInView.swift
//  Investing
//
//  Created by Sergey Balashov on 10.02.2021.
//

import Combine
import InvestModels
import SwiftUI

extension Operation {
    var money: MoneyAmount {
        MoneyAmount(currency: currency, value: payment)
    }
}

class PayInViewModel: EnvironmentCancebleObject, ObservableObject {
    struct Row: Hashable, Identifiable {
        let date: Date
        let money: MoneyAmount
    }

    struct Section: Hashable, Identifiable {
        let row: [Row]

        var header: String {
            if let row = row.first?.date {
                return DateFormatter.format("MM yyyy").string(from: row)
            }
            return "no rows"
        }
    }

    @Published var sections: [Section] = []

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
                    return Section(row: values.map { Row(date: $0.date, money: $0.money) })
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

struct PayInView: View {
    @ObservedObject var viewModel: PayInViewModel

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section(header: Text(section.header)) {
                    ForEach(section.row) { row in
                        HStack {
                            Text(row.date.description)
                            Spacer()
                            MoneyText(money: row.money)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Payble")
        .onAppear(perform: viewModel.load)
    }
}
