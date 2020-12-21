//
//  InstrumentsService.swift
//  Investing
//
//  Created by Sergey Balashov on 09.12.2020.
//

import Foundation
import Moya
import Combine
import InvestModels

class InstrumentsStorage: CancebleObservableObject {
    let service = InstrumentsService()
    @Published var instruments: [Instrument] = []
    
    override init() {
        super.init()
        
        if let saved = Storage.instruments {
            self.instruments = decondingSave(data: saved)
        } else {
            service.getBonds().combineLatest(service.getStocks(), service.getCurrency()) { $0 + $1 + $2 }
                .print("getBonds")
                .eraseToAnyPublisher().replaceError(with: [])
                .assign(to: \.instruments, on: self)
                .store(in: &cancellables)
            
            $instruments.sink { (instuments) in
                if let data = try? JSONEncoder().encode(instuments) {
                    Storage.instruments = data
                }
            }.store(in: &cancellables)
        }
    }
    
    private func decondingSave(data: Data) -> [Instrument] {
        let decoder = JSONDecoder()
        do {
            let instruments = try decoder.decode([Instrument].self, from: data)
            return instruments
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }
}

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
