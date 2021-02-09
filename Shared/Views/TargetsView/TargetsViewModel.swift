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
        let position: Position
    }

    struct TargetPair: Hashable {
        let positionId: String
        var target: Double
    }
}

class TargetsViewModel: EnvironmentCancebleObject, ObservableObject {
    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }

    @Published var columns: [Column] = []
    @State var targets: Set<TargetPair> = []

    var curency: Currency {
        env.settings.currency ?? .RUB
    }

    var total: Double {
        let total = env.api().positionService.positions.reduce(0) { result, position in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: position.totalInProfile,
                                                    to: curency).value
        } + env.api().positionService.currencies.reduce(0) { result, currency in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: currency.money,
                                                    to: curency).value
        }
//        debugPrint("total", total)
        return total
    }

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest(env.api().positionService.$positions,
                                 env.api().positionService.$currencies)
            .receive(on: DispatchQueue.global())
            .map { positions, _ -> [Column] in
                positions.compactMap { [unowned self] (position) -> Column? in
                    let convert = CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                 money: position.totalInProfile,
                                                                 to: curency).value
                    return Column(percent: convert / total,
                                  target: convert / total,
                                  position: position)
                }.sorted(by: { $0.percent > $1.percent })
            }
//            .print("targets")
            .receive(on: DispatchQueue.main)
            .assign(to: \.columns, on: self)
            .store(in: &cancellables)

        $columns.filter { !$0.isEmpty }
            .collect(1).print("set targets")
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .map { columns -> Set<TargetsViewModel.TargetPair> in
                let arr = columns.flatMap {
                    $0.map { column -> TargetPair in
                        TargetPair(positionId: column.position.figi.orEmpty, target: column.target)
                    }
                }
                return Set(arr)
            }
            .assign(to: \.targets, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().positionService.getPositions()
        env.api().positionService.getCurrences()
    }
}
