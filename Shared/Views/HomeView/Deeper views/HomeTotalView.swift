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
