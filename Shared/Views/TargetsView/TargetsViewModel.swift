//
//  TargetsViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 08.02.2021.
//

import Combine
import Foundation
import InvestModels
import SwiftUI

extension TargetsViewModel {
    struct Column: Hashable, Identifiable {
        let percent: Double
        var percentVisible: Double { percent * 100 }
        var target: Double
        let position: SimplePosition
    }
}

class TargetsViewModel: EnvironmentCancebleObject, ObservableObject {
    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }

    @Published var columns: [Column] = []

    @Published var targets: [String: Double] {
        willSet {
            env.settings.targetPositions = newValue
        }
    }

    override init(env: Environment = .current) {
        _targets = .init(initialValue: env.settings.targetPositions)

        super.init(env: env)
    }

    var curency: Currency {
        env.settings.currency ?? .RUB
    }

    var total: Double {
        let total: Double = env.api().positionService.positions.reduce(0) { result, position in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: position.totalInProfile,
                                                    to: curency).value
        }
//        debugPrint("total", total)
        return total
    }

    override func bindings() {
        super.bindings()
        env.api().positionService.$positions
            .receive(on: DispatchQueue.global())
            .map { positions -> [Column] in
                positions.compactMap { [unowned self] (position) -> Column? in
                    let averageNow = CurrencyConvertManager
                        .convert(currencyPair: currencyPairServiceLatest.latest,
                                 money: position.averagePositionPriceNow,
                                 to: curency)

                    let convert = CurrencyConvertManager
                        .convert(currencyPair: currencyPairServiceLatest.latest,
                                 money: position.totalInProfile,
                                 to: curency).value

                    let precent = convert / total

                    return Column(percent: precent,
                                  target: targets[position.ticker] ?? precent * 100,
                                  position: .init(position: position, averageNow: averageNow))
                }
                .sorted(by: { $0.percent > $1.percent })
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.columns, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().positionService.getPositions()
//        env.api().positionService.getCurrences()
    }
}
