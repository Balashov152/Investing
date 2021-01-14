//
//  PositionRowView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import InvestModels
import SwiftUI

struct PositionRowView: View {
    let position: Position

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(position.name.orEmpty).lineLimit(1)
                        .font(.system(size: 17, weight: .bold))
                    Text("$\(position.ticker.orEmpty)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.gray)
                }
                Spacer()
                Text(position.lots.string + " pcs")
                    .font(.system(size: 17, weight: .bold))
            }
            Spacer(minLength: 8)
            HStack {
                leftStack
                Spacer()
                rightStack
            }
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    var leftStack: some View {
        HStack {
            VStack(alignment: .leading) {
                if position.lots > 1 {
                    Text("Avg:")
                }
                Text("Total:")
            }
            VStack(alignment: .leading) {
                if position.lots > 1 {
                    CurrencyText(money: position.averagePositionPrice)
                }
                CurrencyText(money: position.totalBuyPayment)
            }
            Image(systemName: "arrow.forward")
            VStack(alignment: .leading) {
                if position.lots > 1 {
                    CurrencyText(money: position.averagePositionPriceNow)
                }
                CurrencyText(money: position.totalInProfile)
            }
        }.font(.system(size: 14))
    }

    var rightStack: some View {
        HStack(spacing: 4) {
            VStack(alignment: .trailing) {
                if position.lots > 1 {
                    MoneyText(money: position.deltaAveragePositionPrice)
                }
                MoneyText(money: position.expectedYield)
            }

            Image(systemName: position.expectedYield.value > 0 ? "arrow.up" : "arrow.down")
                .foregroundColor(Color.currency(value: position.expectedYield.value))

            Text(position.expectedPercent.string(f: ".2") + "%")
                .foregroundColor(Color.currency(value: position.expectedYield.value))

        }.font(.system(size: 14, weight: .semibold))
    }
}

extension Position {
    static let tesla = Position(name: "Tesla",
                                figi: "3125FSDGA135", ticker: "TSLA",
                                isin: "!512FAF", instrumentType: .Stock,
                                balance: 1000, blocked: 0, lots: 10,
                                expectedYield: MoneyAmount(currency: .USD, value: 2534), // changes
                                averagePositionPrice: MoneyAmount(currency: .USD, value: 87), // avg when buy, with ndk if bond
                                averagePositionPriceNoNkd: nil) // avg when buy without nkd if bond
}
