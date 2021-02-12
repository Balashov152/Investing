//
//  RatesViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation

class RatesViewModel: EnvironmentCancebleObject, ObservableObject {
    var latestService: CurrencyPairServiceLatest { .shared }
}
