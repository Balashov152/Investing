//
//  CurrencyPositionRowView.swift
//  Investing
//
//  Created by Sergey Balashov on 02.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct CurrencyPositionRowView: View {
    let position: PositionView

    var body: some View {
        HStack {
            if let url = InstrumentLogoService.logoUrl(for: position) {
                URLImage(url: url) { image in
                    image
                        .scaledToFit()
                        .cornerRadius(25)
                        .frame(width: 30, height: 30)
                }
            }

            Text(position.currency.rawValue).lineLimit(1)
                .font(.system(size: 17, weight: .bold))

            Spacer()

            rightStack
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    var rightStack: some View {
        HStack(spacing: 4) {
            Text("Total:")
            MoneyText(money: position.totalInProfile)
        }.font(.system(size: 14, weight: .semibold))
    }
}
