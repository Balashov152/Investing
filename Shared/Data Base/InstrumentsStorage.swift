//
//  InstrumentsStorage.swift
//  Investing
//
//  Created by Sergey Balashov on 23.12.2020.
//

import Combine
import Foundation
import InvestModels

class InstrumentsStorage: CancebleObject {
    let service = InstrumentsService()
    @Published var instruments: [Instrument] = []

    override init() {
        super.init()

        if let saved = Storage.instruments {
            instruments = decondingSave(data: saved)
        } else {
            service.getBonds().combineLatest(service.getStocks(), service.getCurrency()) { $0 + $1 + $2 }
                .print("getBonds")
                .eraseToAnyPublisher().replaceError(with: [])
                .assign(to: \.instruments, on: self)
                .store(in: &cancellables)

            $instruments.sink { instuments in
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
