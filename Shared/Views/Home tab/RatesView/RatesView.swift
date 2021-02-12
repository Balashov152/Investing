//
//  RatesView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

extension CurrencyPair {
    func localized(currency: Currency) -> String {
        switch currency {
        case .USD:
            return (1 / USD).formattedCurrency()
        case .EUR:
            return (1 / EUR).formattedCurrency()
        default:
            return ""
        }
    }
}

class RatesViewModel: EnvironmentCancebleObject, ObservableObject {
    var latestService: CurrencyPairServiceLatest { .shared }
}

struct RatesView: View {
    @ObservedObject var viewModel: RatesViewModel

    var body: some View {
        List {
            convertedExchangeRates
        }
    }

    var convertedExchangeRates: some View {
        Group {
            if let latest = viewModel.latestService.latest {
                HStack {
                    Text("USD")
                    Text(latest.localized(currency: .USD))

                    Text("EUR")
                    Text(latest.localized(currency: .EUR))
                }.padding()
            } else {
                Text("not avalible")
            }
        }
    }
}
