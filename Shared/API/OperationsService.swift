//
//  OperationsService.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import Moya
import Combine
import InvestModels

struct OperationsService {
    let provider = ApiProvider<OperationAPI>()
    func getOperations(request: OperationsRequest) -> AnyPublisher<[Operation], MoyaError> {
        provider.request(.getOperations(request: request))
            .map(APIBaseModel<OperationsPayload>.self, using: .standart)
            .map { $0.payload?.operations ?? [] }
            .map { $0.filter { $0.status == .some(.Done) } }
            .eraseToAnyPublisher()
    }
    
    struct OperationsRequest: Encodable {
        let from, to: Date
    }
}

enum OperationAPI {
    case getOperations(request: OperationsService.OperationsRequest)
}

extension OperationAPI: TargetType {
    var path: String { "/operations" }
    
    var method: Moya.Method { .get }
    
    var task: Task {
        switch self {
        case let .getOperations(request):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return .requestCustomParametersEncodable(request, encoder: encoder)
        }
    }
}
