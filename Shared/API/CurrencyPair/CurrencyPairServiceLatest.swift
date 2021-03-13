//
//  CurrencyPairServiceLatest.swift
//  Investing
//
//  Created by Sergey Balashov on 10.02.2021.
//

import Foundation
import InvestModels

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
        env.api().currencyPairService.getLatest()
            .replaceError(with: nil)
            .assign(to: \.latest, on: self)
            .store(in: &cancellables)
        /*
         env.api().positionService().$positions.map {
             $0.filter { $0.instrumentType == .Currency }
         }
         .filter { !$0.isEmpty }
         .flatMap { [unowned self] positions -> AnyPublisher<[Candle], MoyaError> in
             let from = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
             return env.api().candlesService.getCandles(request: CandlesService.RequestCandles(figi: positions.first!.figi!,
                                                                                               from: from,
                                                                                               to: Date(),
                                                                                               interval: .day))
         }
         .print("candles")
         .replaceError(with: [])
         .sink { candle in
             print("candle", candle)
         }.store(in: &cancellables)
         */
    }
}
