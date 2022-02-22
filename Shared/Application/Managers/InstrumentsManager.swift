//
//  InstrumentsManager.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation

protocol InstrumentsManaging {
    func updateInstruments() -> AnyPublisher<Void, Error>
}

class InstrumentsManager {
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
    func updateInstruments() -> AnyPublisher<Void, Error> {
        shareService.loadShares()
            .receive(on: DispatchQueue.global())
            .tryMap { [weak self] shares -> AnyPublisher<[CandleV2], Error> in
                guard let self = self else {
                    throw PublisherErrors.releaseSelf
                }
                self.realmStorage.saveShares(shares: shares)

                return self.usdCandles()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.global())
            .tryMap { [weak self] usd -> AnyPublisher<[CandleV2], Error> in
                guard let self = self else {
                    throw PublisherErrors.releaseSelf
                }

                self.realmStorage.save(candles: usd)

                return self.eurCandles()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.global())
            .tryMap { [weak self] eur -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    throw PublisherErrors.releaseSelf
                }

                self.realmStorage.save(candles: eur)

                return Result.Publisher(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
            .mapToVoid()
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

enum PublisherErrors: Error {
    case emptyData
    case releaseSelf
}
