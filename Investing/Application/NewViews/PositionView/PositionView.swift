//
//  PositionView.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import SwiftUI

struct PositionView: View {
    private let viewModel: PositionViewModel

    init(viewModel: PositionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Paddings.xs) {
            HStack(alignment: .center, spacing: 0) {
                instrumentInfo

                Spacer()

                VStack(alignment: .trailing, spacing: Constants.Paddings.xxs) {
                    VStack(alignment: .trailing, spacing: 0) {
                        MoneyText(money: viewModel.result)
                        
                        if let percent = viewModel.deltaPercent {
                            Text(percent.percentFormat)
                                .foregroundColor(.currency(value: percent))
                                .font(.caption2)
                        }
                    }
                    
                    if viewModel.inPortfolio == nil {
                        inTinkoffApp
                    }
                }
            }

            HStack(spacing: 0) {
                inPorfolio
                
                if viewModel.inPortfolio != nil {
                    Spacer()
                    
                    inTinkoffApp
                }
            }
        }
        .padding(.trailing, Constants.Paddings.m)
    }

    @ViewBuilder private var instrumentInfo: some View {
        let imageSize: CGFloat = 40

        HStack(alignment: .center, spacing: Constants.Paddings.xs) {
            URLImage(position: viewModel)
                .frame(width: imageSize, height: imageSize)
                .background(Color.litleGray)
                .cornerRadius(imageSize / 2)

            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.name)
                    .bold()
                    .lineLimit(1)

                Text("$" + viewModel.ticker)
                    .font(.caption)
            }
        }
    }

    @ViewBuilder private var inPorfolio: some View {
        HStack(spacing: Constants.Paddings.xxs) {
            if let quantity = viewModel.quantity {
                Text(quantity.string(f: ".0")) + Text("pcs").font(.caption2)
            }
            
            if let currentPrice = viewModel.currentPrice {
                Text("|")
                
                Text(currentPrice.value.formattedCurrency(locale: currentPrice.currency.locale))
            }
            
            if let average = viewModel.average {
                Text("|")
                
                MoneyText(money: average)
            }
        }
        .font(.footnote).bold()
        .foregroundColor(.secondary)
    }

    @ViewBuilder private var inTinkoffApp: some View {
        Button(action: {
            UIApplication.shared.open(viewModel.deeplinkURL)
        }) {
            HStack(spacing: .zero) {
                Text("Tinkoff Invest")

                Image(systemName: "arrow.up.right.circle.fill")
            }
            .font(.caption)
            .foregroundColor(.gray34)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PositionViewPreview: PreviewProvider {
    static let viewModel = PositionViewModel(
        figi: "FIGI",
        name: "Telsa",
        ticker: "TSLA",
        isin: nil,
        uiCurrency: .usd,
        instrumentType: .Stock,
        result: .init(currency: .usd, value: 7324.34),
        inPortfolio: .init(
            quantity: 10,
            price: .init(currency: .usd, value: 300),
            average: .init(currency: .usd, value: 800)
        )
    )

    static var previews: some View {
        PositionView(viewModel: viewModel)
//            .previewLayout(.sizeThatFits)
    }
}

extension Bool {
    var value: Int { self ? 1 : 0 }
}
