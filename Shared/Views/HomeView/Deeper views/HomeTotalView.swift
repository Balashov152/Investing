//
//  HomeTotalView.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Foundation
import SwiftUI

struct HomeTotalView: View {
    let model: TotalViewModeble

    var body: some View {
        VStack(alignment: .leading) {
            CurrencyText(money: model.totalInProfile)
                .font(.system(size: 30, weight: .bold))

            HStack(spacing: 4.0) {
                MoneyText(money: model.expectedProfile)
                    .font(.system(size: 16, weight: .medium))
                PercentText(percent: model.percent)
                    .font(.system(size: 14, weight: .regular))
            }
        }
    }
}
