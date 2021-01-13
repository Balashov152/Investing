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
                positionName
                Spacer()
                Text("Lots: " + position.lots.string)
            }
            .lineLimit(1)
            .font(.system(size: 17, weight: .bold))

            HStack {
                leftStack
                Spacer()
                centralStack
                Spacer()
                rightStack
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        } // .padding()
    }

    var positionName: some View {
        HStack {
            Text(position.name.orEmpty + " (" + position.ticker.orEmpty + ")")
        }
    }

    var leftStack: some View {
        VStack(alignment: .leading) {
            HStack {
                if let value = position.averagePositionPriceNoNkd {
                    Text("Primary:")
                    CurrencyText(money: value)
                }

                if let value = position.averagePositionPrice {
                    Text("Avg:")
                    CurrencyText(money: value)
                }
            }

            if let value = position.averagePositionPrice {
                HStack {
                    Text("Total:")
                    CurrencyText(money: .init(currency: value.currency,
                                              value: Double(position.lots) * value.value))
                }
            }
        }.font(.system(size: 12, weight: .semibold))
    }

    var centralStack: some View {
        VStack(alignment: .center) {
            if let value = position.expectedYield / position.lots {
                MoneyText(money: value)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            if let value = position.expectedYield {
                MoneyText(money: value)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
    }

    var rightStack: some View {
        VStack(alignment: .trailing) {
            if let value = position.averagePositionPriceNow {
                CurrencyText(money: value)
            }

            if let value = position.totalInProfile {
                Text(value.string(f: ".2"))
                    .font(.system(size: 12))
            }
        }
    }
}

// struct PositionRowViewPreview: PreviewProvider {
//    static var previews: some View {
//        PositionRowView(position: .tesla)
//    }
// }

extension Position {
    static let tesla = Position(name: "Tesla",
                                figi: "3125FSDGA135", ticker: "TSLA",
                                isin: "!512FAF", instrumentType: .Stock,
                                balance: 1000, blocked: 0, lots: 10,
                                expectedYield: MoneyAmount(currency: .USD, value: 2534), // changes
                                averagePositionPrice: MoneyAmount(currency: .USD, value: 87), // avg when buy, with ndk if bond
                                averagePositionPriceNoNkd: nil) // avg when buy without nkd if bond
}
