//
//  InstrumentsManager.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation

protocol InstrumentsManaging {
    func updateInstruments() -> AnyPublisher<Void, Error>
}

class InstrumentsManager {
    private let shareService: ShareServing
    private let realmStorage: RealmStoraging

    init(
        shareService: ShareServing,
        realmStorage: RealmStoraging
    ) {
        self.shareService = shareService
        self.realmStorage = realmStorage
    }
}

extension InstrumentsManager: InstrumentsManaging {
    func updateInstruments() -> AnyPublisher<Void, Error> {
        shareService.loadShares()
            .receive(on: DispatchQueue.global())
            .flatMap { [weak self] shares -> AnyPublisher<Void, Error> in
                self?.realmStorage.saveShares(shares: shares)

                return Result.Publisher(()).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
