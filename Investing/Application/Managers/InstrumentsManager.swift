//
//  InstrumentsManager.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation
import InvestingServices
import InvestingStorage

protocol InstrumentsManaging {
    func updateInstruments(progress: @escaping (InstrumentsManager.UpdatingProgress) -> ()) -> AnyPublisher<Void, Error>
}

struct InstrumentsManager {
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
    func updateInstruments(progress: @escaping (UpdatingProgress) -> ()) -> AnyPublisher<Void, Error> {
        let publishers = [
            shareService.loadShares()
                .handleEvents(receiveSubscription: { _ in progress(.shares) }),
            shareService.loadEtfs()
                .handleEvents(receiveSubscription: { _ in progress(.etfs) }),
            shareService.loadBonds()
                .handleEvents(receiveSubscription: { _ in progress(.bonds) }),
            shareService.loadCurrencies()
                .handleEvents(receiveSubscription: { _ in progress(.currencies) }),
        ]
        
        return Publishers.Sequence(sequence: publishers)
            .flatMap(maxPublishers: .max(1), { $0.delay(for: 0.5, scheduler: DispatchQueue.global()) })
            .map { realmStorage.saveShares(shares: $0) }
            .collect(publishers.count)
            .mapVoid()
            .eraseToAnyPublisher()
    }
}

extension InstrumentsManager {
    enum UpdatingProgress: String {
        case shares
        case etfs
        case bonds
        case currencies
    }
}

enum PublisherErrors: Error {
    case emptyData
    case releaseSelf
}
