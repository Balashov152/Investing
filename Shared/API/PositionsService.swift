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

class PositionsService: CancebleObservableObject {
    @Published var positions: [Position] = []

    let provider = ApiProvider<PositionAPI>()
    func getPositions() -> AnyPublisher<[Position], MoyaError> {
        provider.request(.getPositions)
            .map(APIBaseModel<PositionsPayload>.self)
            .map { $0.payload?.positions ?? [] }
            .eraseToAnyPublisher()
    }

    func fillPositions() {
        getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }
}

enum PositionAPI {
    case getPositions
}

extension PositionAPI: TargetType {
    var path: String { "/portfolio" }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case .getPositions:
            return .requestPlain // .requestParameters(parameters: ["brokerAccountId": profileId], encoding: URLEncoding.default)
        }
    }
}
