//
//  CurrencyPairService.swift
//  Investing
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Combine
import InvestModels
import Moya

struct CurrencyPairService {
    let provider: ApiProvider<CurrencyPairAPI>

    func getLatest() -> AnyPublisher<CurrencyPair?, MoyaError> {
        let req = CurrencyRequest(dateInterval: DateInterval(start: Date(), end: Date()))
        return provider.request(.getLatest(request: req))
            .receive(on: DispatchQueue.global())
            .map { CurrencyPairSerializer.serializeLatest(json: $0.json) }
            .eraseToAnyPublisher()
    }

    func getCurrencyPairs(request: CurrencyRequest) -> AnyPublisher<[CurrencyPair], MoyaError> {
        provider.request(.getPairs(request: request))
            .receive(on: DispatchQueue.global())
            .map { CurrencyPairSerializer.serialize(json: $0.json) }
            .eraseToAnyPublisher()
    }
}

extension CurrencyPairService {
    struct CurrencyRequest: Encodable {
        let dateInterval: DateInterval

        let base: Currency = .RUB
        let symbols: [Currency] = [.USD, .EUR]

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(base, forKey: .base)
            try container.encode(symbols.map { $0.rawValue }.joined(separator: ","), forKey: .symbols)

            try container.encode(dateInterval.start.startOfYear, forKey: .start)
            try container.encode(dateInterval.end.endOfYear, forKey: .end)
        }

        enum CodingKeys: String, CodingKey {
            case start = "start_at"
            case end = "end_at"

            case symbols
            case base
        }
    }
}

enum CurrencyPairAPI {
    case getPairs(request: CurrencyPairService.CurrencyRequest)
    case getLatest(request: CurrencyPairService.CurrencyRequest)
}

extension CurrencyPairAPI: TargetType {
    var baseURL: URL { URL(string: "https://api.exchangeratesapi.io")! }
    var path: String {
        switch self {
        case .getLatest:
            return "/latest" // https://api.exchangeratesapi.io?base=USD&symbols=RUB
        case .getPairs:
            return "/history"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .getPairs(request), let .getLatest(request):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(CurrencyPair.dateFormatter)
            return .requestCustomParametersEncodable(request, encoder: encoder)
        }
    }
}
