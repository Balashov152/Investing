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
    }
}
