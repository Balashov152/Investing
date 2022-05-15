//
//  PortfolioService.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine
import Foundation
import InvestModels
import Moya

protocol PortfolioServing {
    func getAccounts() -> AnyPublisher<[BrokerAccount], Error>
    func getPortfolio(accountId: String) -> AnyPublisher<Portfolio, Error>
}

struct PortfolioService {
    let provider = ApiProvider<PortfolioAPI>(isNewApi: true)
}

extension PortfolioService: PortfolioServing {
    func getAccounts() -> AnyPublisher<[BrokerAccount], Error> {
        provider.request(.getAccounts)
            .map([BrokerAccount].self, at: .accounts, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func getPortfolio(accountId: String) -> AnyPublisher<Portfolio, Error> {
        provider.request(.getPortfolio(accountId: accountId))
            .map(Portfolio.self, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

enum PortfolioAPI {
    case getAccounts
    case getPortfolio(accountId: String)
}

extension PortfolioAPI: TargetType {
    var baseURL: URL {
        URL(string: "https://invest-public-api.tinkoff.ru/rest/")!
    }

    var method: Moya.Method { .post }

    var path: String {
        switch self {
        case .getAccounts:
            return "tinkoff.public.invest.api.contract.v1.UsersService/GetAccounts"
        case .getPortfolio:
            return "tinkoff.public.invest.api.contract.v1.OperationsService/GetPortfolio"
        }
    }

    var task: Task {
        switch self {
        case .getAccounts:
            return .requestCompositeParameters(bodyParameters: [:],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: [:])
        case let .getPortfolio(accountId):
            return .requestCompositeParameters(bodyParameters: ["accountId": accountId],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: [:])
        }
    }
}
