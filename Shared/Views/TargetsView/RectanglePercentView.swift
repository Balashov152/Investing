//
//  ColumnView.swift
//  Investing
//
//  Created by Sergey Balashov on 04.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct RectanglePercentView: View {
    let column: TargetsViewModel.Column

    internal init(column: TargetsViewModel.Column) {
        self.column = column
    }

    let padding: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.black.opacity(0.8), lineWidth: 1)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                if column.percent > 0 {
                    Rectangle()
                        .foregroundColor(Color(UIColor.systemBlue))
                        .frame(width: geometry.size.width * CGFloat(column.percent),
                               height: geometry.size.height, alignment: .leading)
                        .cornerRadius(3)
                }
            }
        }
    }
}

//
// struct Preview: PreviewProvider {
//    static var previews: some View {
//        TargetPositionView(column: TargetsViewModel.Column(percent: 0.30, target: 0.70, position: .tsla), changeTarget: .constant(71))
//            .frame(width: UIScreen.main.bounds.width,
//                   height: 20)
//    }
// }

extension Position {
    static let tsla = Position(name: "Tesla", figi: "fasfa", ticker: "TSLA",
                               isin: nil, instrumentType: .Stock, balance: 5600,
                               blocked: nil, lots: 40,
                               expectedYield: .init(currency: .USD, value: 400),
                               averagePositionPrice: .init(currency: .USD, value: 300),
                               averagePositionPriceNoNkd: nil)
}
