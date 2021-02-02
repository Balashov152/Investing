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
    let position: PositionView

    var body: some View {
        VStack(alignment: .leading) {
            topNameStack
            Spacer(minLength: 8)
            HStack {
                leftStack
                Spacer()
                rightStack
            }
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    var topNameStack: some View {
        HStack {
            if let isin = position.isin {
                URLImage(url: LogoService.logoUrl(for: isin)) { image in
                    image
                        .scaledToFit()
                        .cornerRadius(25)
                        .frame(width: 50, height: 50)
                }
            }

            VStack(alignment: .leading) {
                Text(position.name.orEmpty).lineLimit(1)
                    .font(.system(size: 17, weight: .bold))
                Text("$\(position.ticker.orEmpty)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.gray)
                Text(position.lots.string + " pcs")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.gray)
            }

            Spacer()
            percentStack
        }
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
        }.font(.system(size: 14, weight: .semibold))
    }

    var percentStack: some View {
        HStack(spacing: 4) {
            if position.expectedYield.value != 0 {
                Image(systemName: position.expectedYield.value > 0 ? "arrow.up" : "arrow.down")
                    .foregroundColor(Color.currency(value: position.expectedYield.value))
            }

            Text(position.expectedPercent.string(f: ".2") + "%")
                .foregroundColor(Color.currency(value: position.expectedYield.value))
        }.font(.system(size: 16, weight: .semibold))
    }
}
