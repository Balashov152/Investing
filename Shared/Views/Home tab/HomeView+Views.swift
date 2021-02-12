//
//  HomeView+Views.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import InvestModels
import SwiftUI

protocol TotalViewModeble {
    var totalInProfile: MoneyAmount { get }
    var expectedProfile: MoneyAmount { get }
    var percent: Double { get }
}

struct TotalViewModel: TotalViewModeble {
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
}

extension HomeView {
    struct TotalView: View {
        let model: TotalViewModeble

        var body: some View {
            HStack {
                if model.totalInProfile.value > 0 {
                    VStack(alignment: .leading) {
                        CurrencyText(money: model.totalInProfile)
                            .font(.system(size: 20, weight: .medium))

                        HStack {
                            MoneyText(money: model.expectedProfile)
                            PercentText(percent: model.percent)
                        }
                        .font(.system(size: 14, weight: .regular))
                    }
                }
            }
        }
    }

    struct HeaderView: View {
        let section: HomeViewModel.Section

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(section.sectionHeader)
                        .font(.system(size: 18, weight: .medium))
                        .textCase(.uppercase)
                    Spacer(minLength: 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(section.positions, id: \.self) { position in
                                if let url = InstrumentLogoService.logoUrl(for: position) {
                                    URLImage(url: url) { image in
                                        image
                                            .frame(width: 20, height: 20, alignment: .center)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                }

                HStack {
                    ForEach(section.currencies.indexed(), id: \.element) { offset, currency in
                        if offset != 0 { Divider() }

                        if section.totalInProfile(currency: currency) > 0 {
                            VStack(alignment: .leading) {
                                CurrencyText(money: MoneyAmount(currency: currency,
                                                                value: section.totalInProfile(currency: currency)))
                                    .font(.system(size: 20, weight: .medium))
                                if section.totalChanged(currency: currency) != 0 {
                                    HStack {
                                        MoneyText(money: MoneyAmount(currency: currency,
                                                                     value: section.totalChanged(currency: currency)))
                                        PercentText(percent: section.percentChanged(currency: currency))
                                    }
                                    .font(.system(size: 14, weight: .regular))
                                }
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}
