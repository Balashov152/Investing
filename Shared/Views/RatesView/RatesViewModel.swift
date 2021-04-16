//
//  RatesViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

class RatesViewModel: EnvironmentCancebleObject, ObservableObject {
    var latestService: LatestCurrencyService { .shared }

    override func bindings() {
        super.bindings()
        latestService.$latest.eraseToAnyPublisher().unwrap()
            .removeDuplicates(by: { $0.USD == $1.USD && $0.EUR == $1.EUR })
            .sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            }).store(in: &cancellables)
    }
}
