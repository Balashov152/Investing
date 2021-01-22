//
//  HomeView+Views.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import InvestModels
import SwiftUI

extension HomeView {
    struct TotalView: View {
        let currency: Currency
        let positions: [Position]

        var filteredPositions: [Position] {
            positions.filter { $0.currency == currency }
        }

        var totalInProfile: MoneyAmount {
            MoneyAmount(currency: currency, value: filteredPositions.map { $0.totalInProfile }.sum)
        }

        var expectedProfile: MoneyAmount {
            MoneyAmount(currency: currency, value: filteredPositions.map { $0.expectedYield }.sum)
        }

        var percent: Double {
            (expectedProfile.value / totalInProfile.value) * 100
        }

        var body: some View {
            HStack {
                CurrencyText(money: totalInProfile)
                MoneyText(money: expectedProfile)
                PercentText(percent: percent)
            }.font(.system(size: 17, weight: .medium))
        }
    }

    struct HeaderView: View {
        let section: HomeViewModel.Section

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text(section.type.rawValue + "s")
                    .font(.system(size: 18, weight: .medium))
                    .textCase(.uppercase)

                HStack {
                    ForEach(section.currencies.indexed(), id: \.element) { offset, currency in
                        if offset != 0 {
                            Divider()
                        }
                        if section.totalInProfile(currency: currency) > 0 {
                            VStack(alignment: .leading) {
                                CurrencyText(money: MoneyAmount(currency: currency,
                                                                value: section.totalInProfile(currency: currency)))
                                    .font(.system(size: 20, weight: .medium))

                                MoneyText(money: MoneyAmount(currency: currency,
                                                             value: section.totalChanged(currency: currency)))
                                    .font(.system(size: 14, weight: .regular))
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}
