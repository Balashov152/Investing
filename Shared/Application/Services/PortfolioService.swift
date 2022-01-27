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
}

struct PortfolioService {
    let provider = ApiProvider<PortfolioAPI>()
}

extension PortfolioService: PortfolioServing {
    func getAccounts() -> AnyPublisher<[BrokerAccount], Error> {
        provider.request(.getAccounts)
            .map([BrokerAccount].self, at: .accounts, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

enum PortfolioAPI {
    case getAccounts
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
        }
    }

    var task: Task {
        return .requestCompositeParameters(bodyParameters: [:],
                                           bodyEncoding: JSONEncoding.default,
                                           urlParameters: [:])
    }
}
