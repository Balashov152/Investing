//
//  PorfolioPositionView.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels
import SwiftUI

struct PorfolioPositionViewModel: Hashable, Identifiable, LogoPosition {
    var id: String { figi }
    var deeplinkURL: URL { URL(string: "https://www.tinkoff.ru/invest/stocks/\(ticker)")! }

    var average: MoneyAmount? {
        guard let average = inPortfolio?.average, average.value > 0 else {
            return nil
        }

        return average
    }

    var quantity: Double? { inPortfolio?.quantity }
    
    var currentPrice: MoneyAmount? {
        guard let inPortfolio else { return nil }
        return MoneyAmount(
            currency: inPortfolio.price.currency,
            value: inPortfolio.price.value
        )
    }

    var deltaPercent: Double? {
        guard let inPortfolio else { return nil }
        let current = inPortfolio.price.value
        let average = inPortfolio.average.value

        if current < average { // I'm in minus
            let percent = current / average
            return (percent - 1) * 100
        }
        
        let percent = abs(average) / current
        return abs(percent - 1) * 100
    }
    
    let figi: String
    let name: String
    let ticker: String
    let isin: String?

    let uiCurrency: UICurrency
    let instrumentType: InstrumentType

    let result: MoneyAmount
    let inPortfolio: InPortfolio?

    init(
        figi: String,
         name: String,
         ticker: String,
         isin: String? = nil,
         uiCurrency: UICurrency,
         instrumentType: InstrumentType,
         result: MoneyAmount,
         inPortfolio: PorfolioPositionViewModel.InPortfolio?
    ) {
        self.figi = figi
        self.name = name
        self.ticker = ticker
        self.isin = isin
        self.uiCurrency = uiCurrency
        self.instrumentType = instrumentType
        self.result = result
        self.inPortfolio = inPortfolio
    }
}

extension PorfolioPositionViewModel {
    struct InPortfolio: Hashable {
        let quantity: Double
        let price: MoneyAmount
        let average: MoneyAmount
    }
}

struct PorfolioPositionView: View {
    private let viewModel: PorfolioPositionViewModel

    init(viewModel: PorfolioPositionViewModel) {
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

struct PorfolioPositionViewPreview: PreviewProvider {
    static let viewModel = PorfolioPositionViewModel(
        figi: "FIGI",
        name: "Telsa",
        ticker: "TSLA",
        isin: nil,
        uiCurrency: .usd,
        instrumentType: .Stock,
        result: .init(currency: .usd, value: 7324.34),
        inPortfolio: .init(
            quantity: 10,
            price: MoneyAmount(currency: .usd, value: 300),
            average: MoneyAmount(currency: .usd, value: 800)
        )
    )

    static var previews: some View {
        PorfolioPositionView(viewModel: viewModel)
//            .previewLayout(.sizeThatFits)
    }
}
