//
//  InvestResults.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels
import SwiftUI

struct InvestResultsHelper {
    func calculateResults(account: BrokerAccount) -> [InvestResult] {
        let operationWithShare = account.operations
            .filter { $0.instrumentType == .share }

        let uniqFigi = Set(operationWithShare.compactMap { $0.figi })

        let results = uniqFigi.compactMap { figi -> InvestResult? in
            guard let instrument = account.operations.first(where: { $0.figi == figi })?.share else {
                return nil
            }

            var outcome = account.operations
                .filter { $0.figi == figi }
                .reduce(0) { $0 + ($1.payment?.price ?? 0) }
//                .currencySum(to: currency)

            let position = account.portfolio?.positions.first(where: { $0.figi == figi })
            outcome += position?.fullSpend ?? 0

            let result = MoneyAmount(currency: instrument.currency, value: outcome)

            return InvestResult(
                figi: instrument.figi,
                instrument: instrument.name ?? "Non instrument name",
                result: result,
                currentQuantity: position?.quantity?.price ?? 0
            )
        }

        return results
    }
}

extension InvestResultsHelper {
    struct InvestResult: Hashable, Identifiable {
        let figi: String
        let instrument: String
        let result: MoneyAmount
        let currentQuantity: Double?
    }
}

class InvestResultsViewModel: ObservableObject {
    @Published var instruments: [InstrumentResultViewModel] = []

    private let realmStorage: RealmStoraging
    private let investResultsHelper = InvestResultsHelper()

    init(realmStorage: RealmStoraging) {
        self.realmStorage = realmStorage
    }
}

extension InvestResultsViewModel: ViewLifeCycleOperator {
    func onAppear() {
        guard let account = realmStorage.selectedAccounts().first else {
            return
        }

        instruments = investResultsHelper.calculateResults(account: account)
            .map {
                InstrumentResultViewModel(
                    figi: $0.figi,
                    name: $0.instrument,
                    result: $0.result,
                    currentQuantity: $0.currentQuantity ?? 0
                )
            }
    }
}

struct InvestResultsView: View {
    @ObservedObject private var viewModel: InvestResultsViewModel

    init(viewModel: InvestResultsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.instruments) {
            InstrumentResultView(viewModel: $0)
        }
        .addLifeCycle(operator: viewModel)
        .navigationTitle("InvestResultsView")
    }
}

struct InstrumentResultViewModel: Identifiable {
    var id: String { figi }

    let figi: String
    let name: String
    let result: MoneyAmount
    let currentQuantity: Double
}

struct InstrumentResultView: View {
    private let viewModel: InstrumentResultViewModel

    init(viewModel: InstrumentResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Paddings.m) {
            MoneyRow(label: viewModel.name, money: viewModel.result)

            HStack(spacing: Constants.Paddings.xs) {
                Text("В портфеле")

                Text(viewModel.currentQuantity.string(f: ".2"))
            }
        }
    }
}
