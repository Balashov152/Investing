//
//  InstrumentsService.swift
//  Investing
//
//  Created by Sergey Balashov on 09.12.2020.
//

import Combine
import Foundation
import InvestModels
import Moya

struct InstrumentsService {
    let provider = ApiProvider<InstrumentsAPI>()

    func getStocks() -> AnyPublisher<[Instrument], MoyaError> {
        provider.request(.getStocks)
            .map(APIBaseModel<InstrumentsPayload>.self)
            .map { $0.payload?.instruments ?? [] }
            .eraseToAnyPublisher()
    }

    func getBonds() -> AnyPublisher<[Instrument], MoyaError> {
        provider.request(.getBonds)
            .map(APIBaseModel<InstrumentsPayload>.self)
            .map { $0.payload?.instruments ?? [] }
            .eraseToAnyPublisher()
    }

    func getCurrency() -> AnyPublisher<[Instrument], MoyaError> {
        provider.request(.getCurrency)
            .map(APIBaseModel<InstrumentsPayload>.self)
            .map { $0.payload?.instruments ?? [] }
            .eraseToAnyPublisher()
    }
}

enum InstrumentsAPI {
    case getStocks
    case getBonds
    case getCurrency
}

extension InstrumentsAPI: TargetType {
    var path: String {
        switch self {
        case .getStocks:
            return "/market/stocks"
        case .getBonds:
            return "/market/bonds"
        case .getCurrency:
            return "/market/currencies"
        }
    }

    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
}
