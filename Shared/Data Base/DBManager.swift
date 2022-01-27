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
    static let version = 9

    let env: Environment
    let realmManager: RealmManager
    var cancellables = Set<AnyCancellable>()

    lazy var instrumentsService = env.api().instrumentsService
    lazy var candlesService = env.api().candlesService

    var savedInterval: DateInterval? {
        var savedInterval: DateInterval?
        realmManager.syncQueueBlock {
            let sort = NSSortDescriptor(key: "date", ascending: true)
            let objects = realmManager.objects(CurrencyPairR.self, sorted: [sort])

            if let first = objects.first, let last = objects.last {
                savedInterval = DateInterval(start: first.date, end: last.date)
            }
        }

        return savedInterval
    }

    var nowInterval: DateInterval? {
        guard let date = savedInterval?.end,
              !Calendar.current.isDateInToday(date)
        else {
            return nil
        }

        return DateInterval(start: date, end: Date())
    }

    var historyInterval: DateInterval? {
        guard let last = savedInterval?.start else {
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
            realmManager.deleteAllObjects()
            Storage.currentDBVersion = DBManager.version
        }

        let publihser: AnyPublisher<Void, Never>
        if let nowInterval = nowInterval, let historyInterval = historyInterval {
            publihser = Publishers.CombineLatest3(updateInstruments(),
                                                  updateCurrency(interval: nowInterval),
                                                  updateCurrency(interval: historyInterval))
                .eraseToAnyPublisher().mapToVoid()
        } else if let nowInterval = nowInterval {
            publihser = Publishers.CombineLatest(updateInstruments(),
                                                 updateCurrency(interval: nowInterval))
                .eraseToAnyPublisher().mapToVoid()
        } else if let historyInterval = historyInterval {
            publihser = Publishers.CombineLatest(updateInstruments(),
                                                 updateCurrency(interval: historyInterval))
                .eraseToAnyPublisher().mapToVoid()
        } else {
            publihser = updateInstruments()
                .eraseToAnyPublisher().mapToVoid()
        }

        return publihser
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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
            .flatMap { [unowned realmManager] instuments -> AnyPublisher<Void, Never> in
                realmManager.write(objects: instuments)
                return Just(()).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    mutating func updateCurrency(interval: DateInterval) -> AnyPublisher<Void, Never> {
        let usd = candlesService
            .getCandles(request: .currency(figi: .USD, date: interval, interval: .day))
            .replaceError(with: []).eraseToAnyPublisher()

        let eur = candlesService
            .getCandles(request: .currency(figi: .EUR, date: interval, interval: .day))
            .replaceError(with: []).eraseToAnyPublisher()

        return Publishers.CombineLatest(usd, eur)
            .receive(on: realmManager.syncQueue)
            .flatMap { [unowned realmManager] usds, euros -> AnyPublisher<Void, Never> in
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
}
