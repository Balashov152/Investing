//
//  PorfolioPositionView.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import InvestModels
import SwiftUI

struct PorfolioPositionViewModel: LogoPosition {
    let name: String
    let ticker: String
    var isin: String?

    let currency: Currency
    let instrumentType: InstrumentType

    let result: MoneyAmount
    let inPortfolio: InPortfolio?

    var average: MoneyAmount {
        .zero
    }
}

extension PorfolioPositionViewModel {
    struct InPortfolio {
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

                MoneyText(money: viewModel.result)
            }

            inPorfolio
        }
        .padding(.horizontal)
    }

    @ViewBuilder private var instrumentInfo: some View {
        let imageSize: CGFloat = 50

        HStack(alignment: .center, spacing: Constants.Paddings.xs) {
            URLImage(position: viewModel)
                .frame(width: imageSize, height: imageSize)
                .background(Color.litleGray)
                .cornerRadius(imageSize / 2)

            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.name)
                    .bold()

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
}

struct PorfolioPositionViewPreview: PreviewProvider {
    static let viewModel = PorfolioPositionViewModel(
        name: "Telsa",
        ticker: "TSLA",
        isin: nil,
        currency: .new(currency: .usd) ?? .USD,
        instrumentType: .Stock,
        result: .init(currency: .usd, value: 7324.34),
        inPortfolio: .init(quantity: 10, price: MoneyAmount(currency: .usd, value: 800))
    )

    static var previews: some View {
        PorfolioPositionView(viewModel: viewModel)
//            .previewLayout(.sizeThatFits)
    }
}
