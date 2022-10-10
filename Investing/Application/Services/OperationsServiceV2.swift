//
//  OperationsServiceV2.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation
import Moya

protocol OperationsServing {
    func loadOperations(for account: BrokerAccount) -> AnyPublisher<[OperationV2], Error>
}

class OperationsServiceV2 {
    let provider = ApiProvider<OperationsAPI>(isNewApi: true)
}

extension OperationsServiceV2: OperationsServing {
    func loadOperations(for account: BrokerAccount) -> AnyPublisher<[OperationV2], Error> {
        let end = Settings.shared.dateInterval.end
        var start = Settings.shared.dateInterval.start
        
        var intervals: [DateInterval] = [DateInterval(start: start.startOfYear, end: start.endOfYear)]
        
        while start.year < end.year {
            start = start.years(value: 1)
            intervals.append(DateInterval(start: start.startOfYear, end: start.endOfYear))
        }
        
        let publishers = intervals.reversed().map { interval -> AnyPublisher<[OperationV2], Error> in
            let parameters = OperationsAPI.OperationParameters(
                accountId: account.id,
                from: interval.start,
                to: interval.end,
                state: .executed,
                figi: nil
            )
            
            return provider.request(.loadOperations(parameters: parameters))
                .map([OperationV2].self, at: .operations, using: .standart)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers).collect(publishers.count)
            .receive(queue: .global())
            .map { $0.reduce([], +) }
            .receive(queue: .main)
            .eraseToAnyPublisher()
    }
}

enum OperationsAPI: TargetType {
    case loadOperations(parameters: OperationParameters)

    var baseURL: URL {
        URL(string: "https://invest-public-api.tinkoff.ru/rest/")!
    }

    var method: Moya.Method { .post }

    var path: String {
        switch self {
        case .loadOperations:
            return "tinkoff.public.invest.api.contract.v1.OperationsService/GetOperations"
        }
    }

    var task: Task {
        switch self {
        case let .loadOperations(parameters):
            return .requestCustomJSONEncodable(parameters, encoder: .standart)
        }
    }
}

extension OperationsAPI {
    struct OperationParameters: Encodable {
        let accountId: String
        let from: Date
        let to: Date
        let state: OperationState?
        let figi: String?

        init(accountId: String, from: Date, to: Date, state: OperationState?, figi: String?) {
            self.accountId = accountId
            self.from = from
            self.to = to
            self.state = state
            self.figi = figi
        }
    }
}
