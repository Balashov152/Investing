//
//  RatesView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import InvestModels
import SwiftUI

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
                Text("rates not found")
            }
        }
    }
}
