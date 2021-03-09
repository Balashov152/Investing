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

class PositionsService: CancebleObject {
    @Published public var positions: [Position] = []
    @Published public var currencies: [CurrencyPosition] = []

    static let shared = PositionsService(provider: .init())

    let provider: ApiProvider<PositionAPI>

    internal init(provider: ApiProvider<PositionAPI>) {
        self.provider = provider
        super.init()

        getPositions()
    }

    func getPositions() {
        provider.request(.getPositions)
            .map(APIBaseModel<PositionsPayload>.self)
            .map { $0.payload?.positions ?? [] }
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }

    func getCurrences() {
        provider.request(.getCurrences)
            .map(APIBaseModel<CurrenciesPayload>.self)
            .map { $0.payload?.currencies ?? [] }
            .replaceError(with: [])
            .assign(to: \.currencies, on: self)
            .store(in: &cancellables)
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
