//
//  CurrencyRow.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import InvestModels
import SwiftUI

struct CurrencyText: View {
    let money: MoneyAmount

    var body: some View {
        Text(money.value.formattedCurrency(locale: money.currency.locale))
    }
}

struct CurrencyRow: View {
    let label: String
    let money: MoneyAmount

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            CurrencyText(money: money)
        }
    }
}
