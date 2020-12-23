//
//  PositionsService.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation
import InvestModels
import Moya

struct PositionsService {
    static let shared = PositionsService()

    let provider = ApiProvider<PositionAPI>()

    func getPositions() -> AnyPublisher<[Position], MoyaError> {
        provider.request(.getPositions)
            .map(APIBaseModel<PositionsPayload>.self)
            .map { $0.payload?.positions ?? [] }
            .eraseToAnyPublisher()
    }

    func getCurrences() -> AnyPublisher<[CurrencyPosition], MoyaError> {
        provider.request(.getCurrences)
            .map(APIBaseModel<CurrenciesPayload>.self)
            .map { $0.payload?.currencies ?? [] }
            .eraseToAnyPublisher()
    }
}

enum PositionAPI {
    case getPositions, getCurrences
}

extension PositionAPI: TargetType {
    var path: String {
        switch self {
        case .getPositions:
            return "/portfolio"
        case .getCurrences:
            return "/portfolio/currencies"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case .getPositions, .getCurrences:
            return .requestPlain
        }
    }
}
