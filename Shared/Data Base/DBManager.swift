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

    lazy var instrumentsService = env.api().instrumentsService
    lazy var candlesService = env.api().candlesService

    init(env: Environment, realmManager: RealmManager) {
        self.env = env
        self.realmManager = realmManager
    }

    mutating func updateIfNeeded() -> AnyPublisher<Void, Never> {
//        guard realmManager.isEmptyDB() || Storage.currentDBVersion < DBManager.version else {
//            didUpdate()
//            return
//        }

        let saveInstruments = Publishers.CombineLatest4(instrumentsService.getBonds(),
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
            }
        
        let interval = env.settings.dateInterval
        let usd = candlesService
            .getCandles(request: .currency(figi: .USD, date: interval, interval: .day))
            .replaceError(with: []).eraseToAnyPublisher()
        
        let eur = candlesService
            .getCandles(request: .currency(figi: .EUR, date: interval, interval: .day))
            .replaceError(with: []).eraseToAnyPublisher()
            

        let saveCurrencyPairs = Publishers.CombineLatest(usd, eur)
            .receive(on: realmManager.syncQueue)
            .flatMap { [unowned realmManager] (usds, euros) -> AnyPublisher<Void, Never> in
                let pairs = interval.range.compactMap { date -> CurrencyPair? in
                    guard let usd = usds.first(where: { $0.date == date }),
                          let eur = euros.first(where: { $0.date == date }) else {
                        return nil
                    }
                    return .init(date: date, USD: usd.avg, EUR: eur.avg)
                }
                
                realmManager.write(objects: pairs)
                return [()].publisher.eraseToAnyPublisher()
            }

        return Publishers.CombineLatest(saveInstruments, saveCurrencyPairs)
            .receive(on: DispatchQueue.main)
            .map { _ in () }.eraseToAnyPublisher()
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
