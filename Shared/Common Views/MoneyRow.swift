//
//  MoneyRow.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import InvestModels
import SwiftUI

struct MoneyText: View {
    let money: MoneyAmount

    var body: some View {
        Text(money.value.formattedCurrency(locale: money.currency.locale))
            .foregroundColor(.currency(value: money.value))
    }
}

struct MoneyRow: View {
    let label: String
    let money: MoneyAmount

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            MoneyText(money: money)
        }
    }
}
