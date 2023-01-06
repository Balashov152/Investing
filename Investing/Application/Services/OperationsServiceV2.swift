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
    func loadOperations(for account: BrokerAccount, progress: @escaping (Progress) -> ()) -> AnyPublisher<[OperationV2], Error>
}

class OperationsServiceV2 {
    let provider = ApiProvider<OperationsAPI>(isNewApi: true)
}

extension OperationsServiceV2: OperationsServing {
    func loadOperations(for account: BrokerAccount, progress: @escaping (Progress) -> ()) -> AnyPublisher<[OperationV2], Error> {
        let parameters = createParameters(accountId: account.id)
        
        let publishers = parameters.map { parameters in
            provider.request(.loadOperations(parameters: parameters))
                .map([OperationV2].self, at: .operations, using: .standart)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        
        var requestNumber = 0
        
        return Publishers.Sequence(sequence: publishers)
            .flatMap(maxPublishers: .max(1)) {
                requestNumber += 1
                progress(Progress(current: requestNumber, all: publishers.count))

                return $0.delay(for: Constants.requestDelay, scheduler: DispatchQueue.global())
            }
            .collect(parameters.count)
            .map { $0.reduce([], +) }
            .eraseToAnyPublisher()
    }
}

extension OperationsServiceV2 {
    func createParameters(accountId: String) -> [OperationsAPI.OperationParameters] {
        let daysInterval: Double = 200
        let periodInSeconds: Double = daysInterval * 24 * 60 * 60 // Days * hours * minutes * seconds
        let targetIntervals = Settings.shared.dateInterval.timeIntervalSinceStartToEnd / periodInSeconds
        let roundedIntervals = Int(targetIntervals.rounded(.up))
        
        let intervals = (0 ..< roundedIntervals).map { period in
            let start = Settings.shared.dateInterval.start
            let startStamp = start.timeIntervalSince1970 + Double(period) * periodInSeconds
            return DateInterval(
                start: Date(timeIntervalSince1970: startStamp),
                end: Date(timeIntervalSince1970: startStamp + periodInSeconds)
            )
        }
        
        return intervals.map { interval -> OperationsAPI.OperationParameters in
            return OperationsAPI.OperationParameters(
                accountId: accountId,
                from: interval.start,
                to: interval.end,
                state: .executed,
                figi: nil // "BBG004731354"
            )
        }.reversed()
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
    struct OperationParameters: Encodable, Hashable {
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
