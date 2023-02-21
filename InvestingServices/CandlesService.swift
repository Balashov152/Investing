//
//  CandlesService.swift
//  Investing
//
//  Created by Sergey Balashov on 13.03.2021.
//

import Combine
import Foundation
import InvestModels
import Moya

struct CandlesService {
    let provider: ApiProvider<CandlesAPI>

    func getCandles(request: RequestCandles) -> AnyPublisher<[Candle], MoyaError> {
        provider.request(.getCandles(body: request))
            .map(APIBaseModel<CandlesPayload>.self, at: APIBaseResponseKey.candles, using: .standart)
            .map { $0.payload?.candles ?? [] }
            .eraseToAnyPublisher()
    }
}

extension CandlesService {
    public struct RequestCandles: Codable {
        let figi: String
        let from: Date
        let to: Date
        let interval: Candle.Interval

        static func currency(figi: Constants.FIGI,
                             date: DateInterval,
                             interval: Candle.Interval = .day) -> RequestCandles {
            RequestCandles(figi: figi.rawValue,
                           from: date.start,
                           to: date.end,
                           interval: interval)
        }
    }
}

enum CandlesAPI {
    case getCandles(body: CandlesService.RequestCandles)
}

extension CandlesAPI: TargetType {
    var path: String {
        switch self {
        case .getCandles:
            return "/market/candles"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .getCandles(request):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return .requestCustomParametersEncodable(request, encoder: encoder)
        }
    }
}
