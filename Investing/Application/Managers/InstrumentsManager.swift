//
//  InstrumentsManager.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation

protocol InstrumentsManaging {
    func updateInstruments(progress: @escaping (InstrumentsManager.UpdatingProgress) -> ()) -> AnyPublisher<Void, Error>
}

struct InstrumentsManager {
    private let shareService: ShareServing
    private let realmStorage: RealmStoraging

    init(
        shareService: ShareServing,
        realmStorage: RealmStoraging
    ) {
        self.shareService = shareService
        self.realmStorage = realmStorage
    }
}

extension InstrumentsManager: InstrumentsManaging {
    func updateInstruments(progress: @escaping (UpdatingProgress) -> ()) -> AnyPublisher<Void, Error> {
        let publishers = [
            shareService.loadShares().handleEvents(receiveSubscription: { _ in progress(.shares) }).eraseToAnyPublisher(),
            shareService.loadEtfs().handleEvents(receiveSubscription: { _ in progress(.etfs) }).eraseToAnyPublisher(),
            shareService.loadBonds().handleEvents(receiveSubscription: { _ in progress(.bonds) }).eraseToAnyPublisher(),
            shareService.loadCurrencies().handleEvents(receiveSubscription: { _ in progress(.currencies) }).eraseToAnyPublisher(),
        ]
        
        return Publishers.Sequence(sequence: publishers)
            .flatMap(maxPublishers: .max(1), { $0.delay(for: 0.5, scheduler: DispatchQueue.global()) })
            .map { realmStorage.saveShares(shares: $0) }
            .collect(publishers.count)
            .mapVoid()
            .eraseToAnyPublisher()
//
//        progress(.shares)
//        return shareService.loadShares().delay(for: 0.5, scheduler: DispatchQueue.global())
//            .receive(queue: .global())
//            .map { realmStorage.saveShares(shares: $0) }
//            .flatMap {
//                progress(.etfs)
//                return shareService.loadEtfs()
//            }
//            .map { realmStorage.saveShares(shares: $0) }
//            .flatMap {
//                progress(.bonds)
//                return shareService.loadBonds()
//            }
//            .map { realmStorage.saveShares(shares: $0) }
//            .flatMap {
//                progress(.bonds)
//                return shareService.loadCurrencies()
//            }
//            .map { realmStorage.saveShares(shares: $0) }
//            .retry(3)
//            .eraseToAnyPublisher()
//

        
//        .receive(queue: .global())
//        .map { [weak self] shares, efts, bonds, currencies in
//            self?.realmStorage.saveShares(shares: shares)
//            self?.realmStorage.saveShares(shares: efts)
//            self?.realmStorage.saveShares(shares: bonds)
//            self?.realmStorage.saveShares(shares: currencies)
//
//            return ()
//        }
//        .eraseToAnyPublisher()

//            .receive(on: DispatchQueue.global())
//            .tryMap { [weak self] shares -> AnyPublisher<[CandleV2], Error> in
//                guard let self = self else {
//                    throw PublisherErrors.releaseSelf
//                }
//                self.realmStorage.saveShares(shares: shares)
//
//                return self.usdCandles()
//            }
//            .switchToLatest()
//            .receive(on: DispatchQueue.global())
//            .tryMap { [weak self] usd -> AnyPublisher<[CandleV2], Error> in
//                guard let self = self else {
//                    throw PublisherErrors.releaseSelf
//                }
//
//                self.realmStorage.save(candles: usd)
//
//                return self.eurCandles()
//            }
//            .switchToLatest()
//            .receive(on: DispatchQueue.global())
//            .tryMap { [weak self] eur -> AnyPublisher<Void, Error> in
//                guard let self = self else {
//                    throw PublisherErrors.releaseSelf
//                }
//
//                self.realmStorage.save(candles: eur)
//
//                return Result.Publisher(()).eraseToAnyPublisher()
//            }
//        .eraseToAnyPublisher()
//        .mapToVoid()
    }
}

private extension InstrumentsManager {
    func usdCandles() -> AnyPublisher<[CandleV2], Error> {
        let format = "dd-MM-yyyy"
        let years = Calendar.current.dates(
            from: Settings.shared.dateInterval.start.days(value: 10),
            to: Settings.shared.dateInterval.end,
            by: .year,
            in: format
        )

        let requests = years.map { year -> AnyPublisher<[CandleV2], Error> in
            let date = Date.from(string: year, format: format)!
            let interval = DateInterval(start: date.startOfYear, end: date.endOfYear.days(value: -1))

            return shareService.loadCandles(
                figi: Constants.FIGI.USD.value,
                dateInterval: interval,
                interval: .CANDLE_INTERVAL_DAY
            )
        }

        return requests.combineLatest.map { array in
            array.reduce([]) { $0 + $1 }
        }
        .eraseToAnyPublisher()
    }

    func eurCandles() -> AnyPublisher<[CandleV2], Error> {
        let format = "YYYY"
        let years = Calendar.current.dates(
            from: Settings.shared.dateInterval.start,
            to: Settings.shared.dateInterval.end,
            by: .year,
            in: format
        )

        let requests = years.map { year -> AnyPublisher<[CandleV2], Error> in
            let date = Date.from(string: year, format: format)!
            let interval = DateInterval(start: date.startOfYear, end: date.endOfYear.days(value: -1))

            return shareService.loadCandles(
                figi: Constants.FIGI.EUR.value,
                dateInterval: interval,
                interval: .CANDLE_INTERVAL_DAY
            )
        }

        return requests.combineLatest.map {
            $0.reduce([], +)
        }
        .eraseToAnyPublisher()
    }

    func loadUSDCandles(interval: DateInterval) -> AnyPublisher<[CandleV2], Error> {
        shareService.loadCandles(
            figi: Constants.FIGI.USD.value,
            dateInterval: interval,
            interval: .CANDLE_INTERVAL_DAY
        )
    }
}

extension InstrumentsManager {
    enum UpdatingProgress: String {
        case shares
        case etfs
        case bonds
        case currencies
    }
}

enum PublisherErrors: Error {
    case emptyData
    case releaseSelf
}
