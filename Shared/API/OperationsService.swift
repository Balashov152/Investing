//
//  OperationsService.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import InvestModels
import Moya

class OperationsService: CancebleObject, ObservableObject {
    let provider = ApiProvider<OperationAPI>()

    @Published public var operations: [Operation] = []

    func getOperations(request: OperationsRequest) {
        guard operations.isEmpty else { return } // think about it

        provider.request(.getOperations(request: request))
            .receive(on: DispatchQueue.global()).eraseToAnyPublisher()
            .map(APIBaseModel<OperationsPayload>.self, using: .standart)
            .map { $0.payload?.operations ?? [] }
            .replaceError(with: [])
            .map { $0.filter { $0.status == .some(.Done) } }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }
}

extension OperationsService {
    struct OperationsRequest: Encodable {
        let from, to: Date

        internal init(from: Date, to: Date) {
            self.from = from
            self.to = to
        }

        internal init(env: Environment) {
            from = env.dateInterval().start
            to = env.dateInterval().end
        }
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
