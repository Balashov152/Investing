//
//  ShareService.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation
import Moya
import InvestModels

public protocol ShareServing {
    func loadBonds() -> AnyPublisher<[Share], Error>
    func loadEtfs() -> AnyPublisher<[Share], Error>
    func loadShares() -> AnyPublisher<[Share], Error>
    func loadCurrencies() -> AnyPublisher<[Share], Error>
//    func loadCandles(figi: String, dateInterval: InvestModels.DateInterval, interval: CandleV2.Interval) -> AnyPublisher<[CandleV2], Error>
}

struct ShareService {
    let provider = ApiProvider<ShareAPI>()
}

extension ShareService: ShareServing {
    func loadBonds() -> AnyPublisher<[Share], Error> {
        provider.request(.loadBonds(status: .INSTRUMENT_STATUS_UNSPECIFIED))
            .map([Share].self, at: .instruments, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func loadEtfs() -> AnyPublisher<[Share], Error> {
        provider.request(.loadEtfs(status: .INSTRUMENT_STATUS_UNSPECIFIED))
            .map([Share].self, at: .instruments, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func loadShares() -> AnyPublisher<[Share], Error> {
        provider.request(.loadShares(status: .INSTRUMENT_STATUS_UNSPECIFIED))
            .map([Share].self, at: .instruments, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func loadCurrencies() -> AnyPublisher<[Share], Error> {
        provider.request(.loadCurrencies(status: .INSTRUMENT_STATUS_UNSPECIFIED))
            .map([Share].self, at: .instruments, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

//    func loadCandles(figi: String, dateInterval: InvestModels.DateInterval, interval: CandleV2.Interval) -> AnyPublisher<[CandleV2], Error> {
//        provider.request(.loadCandles(figi: figi, dateInterval: dateInterval, interval: interval))
//            .map([CandleV2].self, at: .candles, using: .standart)
//            .map {
//                let candles = $0
//                candles.forEach { $0.figi = figi }
//                return candles
//            }
//            .mapError { $0 as Error }
//            .eraseToAnyPublisher()
//    }
}

enum ShareAPI: TargetType {
    case loadBonds(status: ShareStatus)
    case loadEtfs(status: ShareStatus)
    case loadShares(status: ShareStatus)
    case loadCurrencies(status: ShareStatus)

    case loadCandles(figi: String, dateInterval: InvestModels.DateInterval, interval: CandleV2.Interval)

    var baseURL: URL {
        URL(string: "https://invest-public-api.tinkoff.ru/rest/")!
    }

    var method: Moya.Method { .post }

    var path: String {
        switch self {
        case .loadBonds:
            return "tinkoff.public.invest.api.contract.v1.InstrumentsService/Bonds"
        case .loadEtfs:
            return "tinkoff.public.invest.api.contract.v1.InstrumentsService/Etfs"
        case .loadShares:
            return "tinkoff.public.invest.api.contract.v1.InstrumentsService/Shares"
        case .loadCurrencies:
            return "tinkoff.public.invest.api.contract.v1.InstrumentsService/Currencies"
        case .loadCandles:
            return "tinkoff.public.invest.api.contract.v1.MarketDataService/GetCandles"
        }
    }

    var task: Task {
        switch self {
        case let .loadShares(status),
            let .loadEtfs(status),
            let .loadBonds(status),
            let .loadCurrencies(status):
            return .requestCompositeParameters(bodyParameters: ["instrumentStatus": status.rawValue],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: [:])
        case let .loadCandles(figi: figi, dateInterval: dateInterval, interval: interval):
            return .requestCompositeParameters(
                bodyParameters: [
                    "figi": figi,
                    "from": dateInterval.start.string(formatter: .iso8601),
                    "to": dateInterval.end.string(formatter: .iso8601),
                    "interval": interval.rawValue,
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        }
    }
}

extension ShareAPI {
    enum ShareStatus: String {
        case INSTRUMENT_STATUS_UNSPECIFIED, INSTRUMENT_STATUS_BASE, INSTRUMENT_STATUS_ALL
    }
}
