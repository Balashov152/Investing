//
//  CurrencyPairServiceLatest.swift
//  Investing
//
//  Created by Sergey Balashov on 10.02.2021.
//

import Combine
import Foundation
import InvestModels
import Moya

class CurrencyPairServiceLatest: EnvironmentCancebleObject, ObservableObject {
    static let shared = CurrencyPairServiceLatest()

    @Published public var latest: CurrencyPair?
    private var timer: Timer?

    override private init(env: Environment = .current) {
        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        update()
//        timer = .scheduledTimer(withTimeInterval: 10, repeats: true) { [unowned self] _ in
//            update()
//        }
    }

    func update() {
        let candlesInterval = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let interval = DateInterval(start: candlesInterval, end: Date())

        let lastUSD = env.api().candlesService
            .getCandles(request: .currency(figi: .USD,
                                           date: interval))
            .replaceError(with: [])
            .map { $0.last }
            .eraseToAnyPublisher().unwrap()

        let lastEUR = env.api().candlesService
            .getCandles(request: .currency(figi: .EUR,
                                           date: interval))
            .replaceError(with: [])
            .map { $0.last }
            .eraseToAnyPublisher().unwrap()

        Publishers.CombineLatest(lastUSD, lastEUR)
            .map { CurrencyPair(date: Date(), USD: $0.0.avg, EUR: $0.1.avg) }
            .assign(to: \.latest, on: self)
            .store(in: &cancellables)
    }
}
