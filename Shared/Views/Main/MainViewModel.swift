//
//  MainViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import Foundation

class MainViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var loadDB: LoadingState<Void> = .loading
    var dbManager: DBManager
    var latest: CurrencyPairServiceLatest { .shared }

    override init(env: Environment = .current) {
        dbManager = DBManager(env: env, realmManager: RealmManager())

        super.init(env: env)
    }

    func loadData() {
        guard loadDB == .loading else { return }

        Publishers.CombineLatest(dbManager.updateIfNeeded(), latest.$latest.dropFirst())
            .eraseToAnyPublisher().mapToVoid()
            .map { .loaded(object: $0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.loadDB, on: self)
            .store(in: &cancellables)
    }
}
