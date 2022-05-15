//
//  AccountService.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation
import InvestModels
import Moya

struct AccountService {
    let provider: ApiProvider<ProfileAPI>

    func getAccounts() -> AnyPublisher<[Account], MoyaError> {
        provider.request(.getProfile)
            .map(APIBaseModel<AccountsPayload>.self)
            .map { $0.payload?.accounts ?? [] }
            .eraseToAnyPublisher()
    }

    func getBrokerAccount() -> AnyPublisher<Account?, MoyaError> {
        getAccounts()
            .map {
                $0.first(where: { $0.brokerAccountType == "Tinkoff" })
            }
            .eraseToAnyPublisher()
    }
}

enum ProfileAPI {
    case getProfile
}

extension ProfileAPI: TargetType {
    var path: String { "/user/accounts" }

    var method: Moya.Method { .get }

    var task: Task { .requestPlain }
}
