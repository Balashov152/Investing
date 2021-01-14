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
    @Published public var operations: [Operation] = []
    private var loadOperationForInterval: DateInterval?

    private let provider = ApiProvider<OperationAPI>()
    private let realmManager: RealmManager

    init(realmManager: RealmManager) {
        self.realmManager = realmManager

        super.init()
    }

    func getOperations(request: OperationsRequest) {
        guard Settings.shared.dateInterval != loadOperationForInterval || operations.isEmpty else { return } // think about it

        provider.request(.getOperations(request: request))
            .receive(on: DispatchQueue.global()).eraseToAnyPublisher()
            .map(APIBaseModel<OperationsPayload>.self, using: .standart)
            .map { $0.payload?.operations ?? [] }
            .replaceError(with: [])
            .map { $0.filter { $0.status == .some(.Done) } }
            .receive(on: realmManager.syncQueue)
            .map { [unowned self] operations -> [Operation] in
                operations.map { operation -> Operation in
                    var newOperation = operation
                    self.fillOperationFromDB(operation: &newOperation)
                    return newOperation
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }

    func fillOperationFromDB(operation: inout Operation) {
        if let figi = operation.figi,
           let instrumentR = realmManager.object(InstrumentR.self, for: figi)
        {
            operation.instrument = Instrument(instrument: instrumentR)
        }

        if let pair = realmManager.object(CurrencyPairR.self,
                                          for: CurrencyPair.dateFormatter.string(from: operation.date))
        {
            operation.currencyPair = CurrencyPair(currencyPairR: pair)
        }
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
            from = env.dateInterval().start.startOfDay
            to = env.dateInterval().end.endOfDay
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
