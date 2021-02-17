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
        VStack {
            top
            Spacer(minLength: 8)
            bottom
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    var top: some View {
        HStack(alignment: .top) {
            topNameStack
            Spacer()
            VStack(alignment: .trailing) {
                CurrencyText(money: position.totalInProfile)
                    .font(.system(size: 17, weight: .medium))

//                .padding(.all, 3)
//                .foregroundColor(.black)
//                .background(Color.black.opacity(0.1))
//                .cornerRadius(5)

                if position.percentInProfile > 0 {
                    Text("weight " + position.percentInProfile.string(f: ".2") + "%")
                        .font(.system(size: 12, weight: .regular))
                }
            }
        }
    }

    var bottom: some View {
        HStack {
            leftStack
            Spacer()
            percentStack
        }
    }

    var topNameStack: some View {
        VStack(alignment: .leading) {
            HStack {
                if let isin = position.isin {
                    URLImage(url: LogoService.logoUrl(for: isin)) { image in
                        image
                            .scaledToFit()
                            .cornerRadius(25)
                            .frame(width: 50, height: 50)
                    }
                }

                VStack(alignment: .leading, spacing: 4.0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(position.name.orEmpty).lineLimit(1)
                            .font(.system(size: 17, weight: .bold))
                        Text("$\(position.ticker.orEmpty)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.gray)
                    }

                    HStack(spacing: 4) {
                        Text(position.lots.string(f: ".0") + " pcs")
                        Text("|")
                        CurrencyText(money: position.averagePositionPriceNow)
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.gray34)
                }
            }
        }
    }

    var leftStack: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("average")
                HStack(spacing: 4.0) {
                    CurrencyText(money: position.averagePositionPrice)
                    Text("|")
                    CurrencyText(money: position.totalBuyPayment)
                }.lineLimit(1)
            }
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(Color.white)
    }

    var rightStack: some View {
        CurrencyText(money: position.totalInProfile)
            .foregroundColor(Color.currency(value: position.expectedYield.value))
            .font(.system(size: 17, weight: .semibold))
    }

    var percentStack: some View {
        HStack {
            if position.expectedYield.value != 0 {
                Image(systemName: position.expectedYield.value > 0 ? "arrow.up" : "arrow.down")
                    .foregroundColor(Color.currency(value: position.expectedYield.value))
            }

            VStack(alignment: .trailing) {
                MoneyText(money: position.expectedYield)
                    .font(.system(size: 16, weight: .semibold))

                Text(position.expectedPercent.string(f: ".2") + "%")
                    .foregroundColor(Color.currency(value: position.expectedYield.value))
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}
