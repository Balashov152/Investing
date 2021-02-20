//
//  BlockedText.swift
//  Investing
//
//  Created by Sergey Balashov on 20.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct BlockedText: View {
    let value: MoneyAmount
    var body: some View {
        CurrencyText(money: value)
            .foregroundColor(.gray)
            .padding(2)
            .background(Color.litleGray)
            .font(.system(size: 12, weight: .medium))
            .cornerRadius(5)
    }
}
