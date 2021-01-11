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
            positionName
            HStack {
                leftStack
                Spacer()
                rightStack
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }

    var positionName: some View {
        HStack {
            Text(position.name.orEmpty + " (" + position.ticker.orEmpty + ")")
        }
        .lineLimit(1)
        .font(.system(size: 17, weight: .bold))
    }

    var leftStack: some View {
        VStack(alignment: .leading) {
            Text("Lots: " + position.lots.string)

            HStack {
                if let value = position.averagePositionPriceNoNkd {
                    Text("Primary:")
                    MoneyText(money: value)
                }

                if let value = position.averagePositionPrice {
                    Text("Avg:")
                    MoneyText(money: value)
                }
            }

            if let value = position.averagePositionPrice {
                HStack {
                    Text("Total:")
                    MoneyText(money: .init(currency: value.currency,
                                           value: Double(position.lots) * value.value))
                }
            }

        }.font(.system(size: 12))
    }

    var rightStack: some View {
        VStack(alignment: .trailing) {
            if let value = position.totalInProfile {
                Text(value.string(f: ".2"))
                    .font(.system(size: 14))
            }

            if let value = position.expectedYield {
                MoneyText(money: value)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
    }
}
