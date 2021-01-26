//
//  TaxView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 18.01.2021.
//

import Combine
import InvestModels
import SwiftUI

class TaxViewModel: EnvironmentCancebleObject, ObservableObject {
    var sum: Double {
        [2.28,
         1.84,
         5.53,
         2.21,
         1.06,
         0.24,
         0.37,
         0.48,
         1.25,
         0.91,
         0.34,
         1.30,
         1.83,
         2.58,
         1.08,
         3.19,
         5.16,
         1.35,
         2.29,
         1.08,
         4.91,
         19.56,
         1.73,
         1.38].sum
    }

    var sumTax: Double {
        [0.20,
         0.62,
         0.25,
         0.12,
         0.55,
         0.04,
         0.06,
         0.25,
         0.10,
         0.04,
         0.29,
         0.14,
         0.21,
         0.00,
         0.12,
         0.35,
         0.58,
         0.15,
         1.24,
         2.17,
         0.19,
         0.26,
         0.12,
         0.15].sum
    }
}

struct TaxView: View {
    @ObservedObject var viewModel: TaxViewModel

    var body: some View {
        List {
            CurrencyRow(label: "Sum", money: MoneyAmount(currency: .USD, value: viewModel.sum))
            CurrencyRow(label: "SumTax", money: MoneyAmount(currency: .USD, value: viewModel.sumTax))
        }
    }
}
