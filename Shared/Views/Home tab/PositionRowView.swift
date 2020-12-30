//
//  PositionRowView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import InvestModels
import SwiftUI

struct PositionRowView: View {
    let position: Position

    var body: some View {
        HStack {
            leftStack
            Spacer()
            rightStack
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    var leftStack: some View {
        VStack(alignment: .leading) {
            Text(position.name.orEmpty).font(.system(size: 17))
            HStack(spacing: 2) {
                if let lots = position.lots {
                    Text(lots.string)
                }

                if let value = position.averagePositionPriceNoNkd?.value {
                    Text("-")
                    Text(value.string(f: ".2"))
                }

                if let value = position.averagePositionPrice?.value {
                    Text("-")
                    Text(value.string(f: ".2"))
                }

            }.font(.system(size: 12))
        }
    }

    var rightStack: some View {
        VStack(alignment: .trailing) {
            if let value = position.totalInProfile {
                Text(value.string(f: ".2"))
                    .font(.system(size: 14))
            }

            if let value = position.expectedYield?.value {
                MoneyText(money: .init(currency: .USD, value: value))
                    .font(.system(size: 14, weight: .semibold))
            }
        }
    }
}
