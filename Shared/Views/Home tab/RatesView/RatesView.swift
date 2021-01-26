//
//  RatesView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

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
                    Text((1 / latest.USD).formattedCurrency())

                    Text("EUR")
                    Text((1 / latest.EUR).formattedCurrency())
                }.padding()
            } else {
                Text("not avalible")
            }
        }
    }
}
