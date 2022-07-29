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

    let figi: String
    let name: String
    let ticker: String
    let isin: String?

    let uiCurrency: UICurrency
    let instrumentType: InstrumentType

    let result: MoneyAmount
    let inPortfolio: InPortfolio?

    let average: MoneyAmount?

    init(figi: String, name: String, ticker: String, isin: String? = nil, uiCurrency: UICurrency, instrumentType: InstrumentType, result: MoneyAmount, inPortfolio: PorfolioPositionViewModel.InPortfolio?, average: MoneyAmount?) {
        self.figi = figi
        self.name = name
        self.ticker = ticker
        self.isin = isin
        self.uiCurrency = uiCurrency
        self.instrumentType = instrumentType
        self.result = result
        self.inPortfolio = inPortfolio
        self.average = average
    }
}

extension PorfolioPositionViewModel {
    struct InPortfolio: Hashable {
        let quantity: Double
        let price: MoneyAmount
    }
}

struct PorfolioPositionView: View {
    private let viewModel: PorfolioPositionViewModel

    init(viewModel: PorfolioPositionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Paddings.xs) {
            HStack(spacing: Constants.Paddings.xxs) {
                instrumentInfo

                Spacer()

                VStack(alignment: .trailing) {
                    MoneyText(money: viewModel.result)

                    Spacer()

                    inTinkoffApp
                }
            }

            inPorfolio
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
        if let inPortfolio = viewModel.inPortfolio {
            HStack(spacing: 4) {
                Text(inPortfolio.quantity.string(f: ".0") + " pcs")

                Text("|")

                MoneyText(money: inPortfolio.price)
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(Color.gray34)
        }
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
        inPortfolio: .init(quantity: 10, price: MoneyAmount(currency: .usd, value: 800)),
        average: nil
    )

    static var previews: some View {
        PorfolioPositionView(viewModel: viewModel)
//            .previewLayout(.sizeThatFits)
    }
}
