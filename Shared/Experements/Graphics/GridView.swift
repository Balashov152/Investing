//
//  GridView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
//        Group {
        ColumnView(column: .init(percent: 0.3256, target: 0.44, position: .tsla),
                   mainSize: CGSize(width: 15, height: 200),
                   changeTarget: .constant(70))
//        }.frame(width: 100, height: 100, alignment: .center)
    }
}

extension Position {
    static let tsla = Position(name: "Tesla",
                               figi: "p375adslkbasd",
                               ticker: "TSLA",
                               isin: "124SAFS41",
                               instrumentType: .Stock,
                               balance: 4500,
                               blocked: 0,
                               lots: 10,
                               expectedYield: .init(currency: .USD, value: 340),
                               averagePositionPrice: .init(currency: .USD, value: 450),
                               averagePositionPriceNoNkd: nil)
}
