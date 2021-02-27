//
//  HomeHeaderView.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct HomeHeaderView: View {
    let section: HomeViewModel.Section

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Text(section.sectionHeader.capitalized)
                    .font(.system(size: 20, weight: .semibold))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(section.positions, id: \.self) { position in
                            URLImage(position: position)
                                .frame(width: 20, height: 20, alignment: .center)
                                .background(Color.litleGray)
                                .cornerRadius(10)
                        }
                    }
                }
            }

            HStack {
                ForEach(section.currencies.sorted(by: >).indexed(), id: \.element) { offset, currency in
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
