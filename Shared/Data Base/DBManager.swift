//
//  DBManager.swift
//  SellFashion
//
//  Created by Sergey Balashov on 05.06.2020.
//  Copyright © 2020 SELLFASHION. All rights reserved.
//

import Combine
import Foundation
import InvestModels

struct DBManager {
    static let version = 4

    let env: Environment
    let realmManager: RealmManager
    var cancellables = Set<AnyCancellable>()

    init(env: Environment, realmManager: RealmManager) {
        self.env = env
        self.realmManager = realmManager
    }

    mutating func updateIfNeeded() -> AnyPublisher<Void, Never> {
//        guard realmManager.isEmptyDB() || Storage.currentDBVersion < DBManager.version else {
//            didUpdate()
//            return
//        }

        let saveInstruments = Publishers.CombineLatest4(env.api().instrumentsService.getBonds(),
                                                        env.api().instrumentsService.getStocks(),
                                                        env.api().instrumentsService.getCurrency(),
                                                        env.api().instrumentsService.getEtfs())
            .map { $0 + $1 + $2 + $3 }
            .replaceError(with: [])
            .receive(on: realmManager.syncQueue)
            .map { $0.map { InstrumentR(instrument: $0) } }
            .flatMap { [unowned realmManager] (instuments) -> AnyPublisher<Void, Never> in
                realmManager.write(objects: instuments)
                return [()].publisher.eraseToAnyPublisher()
            }

        let saveCurrencyPairs = env.api().currencyPairService
            .getCurrencyPairs(request: .init(dateInterval: env.settings.dateInterval))
            .replaceError(with: [])
            .map { $0.map { CurrencyPairR(currencyPair: $0) } }
            .receive(on: realmManager.syncQueue)
            .flatMap { [unowned realmManager] (instuments) -> AnyPublisher<Void, Never> in
                realmManager.write(objects: instuments)
                return [()].publisher.eraseToAnyPublisher()
            }

        return Publishers.CombineLatest(saveInstruments, saveCurrencyPairs)
            .receive(on: DispatchQueue.main)
            .map { _ in () }.eraseToAnyPublisher()
    }

    func updateCurrency() -> AnyPublisher<Void, Never> {
        var lastUpdateCurrency: Date?

        realmManager.syncQueueBlock {
            let sort = NSSortDescriptor(key: "date", ascending: true)
            lastUpdateCurrency = realmManager.objects(CurrencyPairR.self, sorted: [sort]).last?.date
        }

        guard let lastUpdate = lastUpdateCurrency,
              lastUpdate < Calendar.current.startOfDay(for: Date())
        else {
            return [()].publisher.eraseToAnyPublisher()
        }

        return env.api().currencyPairService
            .getCurrencyPairs(request: .init(dateInterval: DateInterval(start: lastUpdate, end: Date())))
            .replaceError(with: [])
            .map { $0.map { CurrencyPairR(currencyPair: $0) } }
            .receive(on: realmManager.syncQueue)
            .flatMap { [unowned realmManager] (instuments) -> AnyPublisher<Void, Never> in
                realmManager.write(objects: instuments)
                return [()].publisher.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
