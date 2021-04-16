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
    static let version = 5

    let env: Environment
    let realmManager: RealmManager
    var cancellables = Set<AnyCancellable>()

    lazy var instrumentsService = env.api().instrumentsService
    lazy var candlesService = env.api().candlesService

    var interval: DateInterval? {
        var lastUpdateCurrency: Date?
        realmManager.syncQueueBlock {
            let sort = NSSortDescriptor(key: "date", ascending: true)
            lastUpdateCurrency = realmManager.objects(CurrencyPairR.self, sorted: [sort]).first?.date
        }

        guard let last = lastUpdateCurrency else {
            return .yearAgo
        }

        if last < env.settings.dateInterval.start {
            return nil
        }

        return DateInterval(start: last.years(value: -1), end: last)
    }

    init(env: Environment, realmManager: RealmManager) {
        self.env = env
        self.realmManager = realmManager
    }

    mutating func updateIfNeeded(force: Bool = false) -> AnyPublisher<Void, Never> {
        if force || Storage.currentDBVersion < DBManager.version {
            realmManager.syncQueueBlock {
                realmManager.objectTypes.forEach {
                    realmManager.deleteAllObjects(type: $0)
                }
            }
            Storage.currentDBVersion = DBManager.version
        }

        return Publishers.CombineLatest(updateInstruments(), updateCurrency())
            .receive(on: DispatchQueue.main)
            .map { _ in () }.eraseToAnyPublisher()
    }

    mutating func updateInstruments() -> AnyPublisher<Void, Never> {
        Publishers.CombineLatest4(instrumentsService.getBonds(),
                                  instrumentsService.getStocks(),
                                  instrumentsService.getCurrency(),
                                  instrumentsService.getEtfs())
            .map { $0 + $1 + $2 + $3 }
            .replaceError(with: [])
            .receive(on: realmManager.syncQueue)
            .map { $0.map { InstrumentR(instrument: $0) } }
            .flatMap { [unowned realmManager] (instuments) -> AnyPublisher<Void, Never> in
                realmManager.write(objects: instuments)
                return [()].publisher.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    mutating func updateCurrency() -> AnyPublisher<Void, Never> {
        guard let interval = self.interval else {
            return [()].publisher.eraseToAnyPublisher()
        }

        let usd = candlesService
            .getCandles(request: .currency(figi: .USD, date: interval, interval: .day))
            .replaceError(with: []).eraseToAnyPublisher()

        let eur = candlesService
            .getCandles(request: .currency(figi: .EUR, date: interval, interval: .day))
            .replaceError(with: []).eraseToAnyPublisher()

        return Publishers.CombineLatest(usd, eur)
            .receive(on: realmManager.syncQueue)
            .flatMap { [unowned realmManager] (usds, euros) -> AnyPublisher<Void, Never> in
                let format = "dd.MM.yyyy"
                let dates = Calendar.current.dates(from: interval.start,
                                                   to: interval.end, in: format)

                let pairs = dates.compactMap { date -> CurrencyPair? in
                    guard let usd = usds.first(where: { $0.time?.string(format: format) == date }),
                          let eur = euros.first(where: { $0.time?.string(format: format) == date }),
                          let date = DateFormatter.format(format).date(from: date)
                    else {
                        return nil
                    }
                    return .init(date: date, USD: usd.avg, EUR: eur.avg)
                }.map(CurrencyPairR.init)

                realmManager.write(objects: pairs)
                return [()].publisher.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    /*
        mutating func updateCurrency() -> AnyPublisher<Void, Never> {
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

            return currencyPairService
                .getCurrencyPairs(request: .init(dateInterval: DateInterval(start: lastUpdate, end: Date())))
                .replaceError(with: [])
                .map { $0.map { CurrencyPairR(currencyPair: $0) } }
                .receive(on: realmManager.syncQueue)
                .flatMap { [unowned realmManager] (instuments) -> AnyPublisher<Void, Never> in
                    realmManager.write(objects: instuments)
                    return [()].publisher.eraseToAnyPublisher()
                }.eraseToAnyPublisher()
        }
     */
}
