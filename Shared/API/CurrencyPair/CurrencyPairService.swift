//
//  CurrencyPairService.swift
//  Investing
//
//  Created by Sergey Balashov on 22.12.2020.
//

import Combine
import InvestModels
import Moya

class CurrencyPairServiceLatest: EnvironmentCancebleObject, ObservableObject {
    @Published public var latest: CurrencyPair?

    var timer: Timer?

    override func bindings() {
        super.bindings()
        update()
        timer = .scheduledTimer(withTimeInterval: 10, repeats: true) { [unowned self] _ in
            update()
        }
    }

    func update() {
        env.api().currencyPairService.getLatest()
            .replaceError(with: nil)
            .assign(to: \.latest, on: self)
            .store(in: &cancellables)
    }
}

struct CurrencyPairService {
    let provider = ApiProvider<CurrencyPairAPI>()

    func getLatest() -> AnyPublisher<CurrencyPair?, MoyaError> {
        let req = CurrencyRequest(dateInterval: DateInterval(start: Date(), end: Date()))
        return provider.request(.getLatest(request: req))
            .receive(on: DispatchQueue.global())
            .map { CurrencyPairSerializer.serialize(json: $0.json).first }
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

            try container.encode(dateInterval.start.startOfDay, forKey: .start)
            try container.encode(dateInterval.end.endOfDay, forKey: .end)
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
            encoder.dateEncodingStrategy = .formatted(.format("yyyy-MM-dd"))
            return .requestCustomParametersEncodable(request, encoder: encoder)
        }
    }
}
