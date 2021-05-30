//
//  OperationRowView.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Combine
import Foundation
import InvestModels
import SwiftUI

extension OperationRowView {
    struct TopView: View {
        let instument: Instrument

        var body: some View {
            HStack {
                if let ticker = instument.ticker,
                   let name = instument.name
                {
                    Text(name + " (\(ticker))").lineLimit(1)
                }
            }.font(.system(size: 17, weight: .semibold))
        }
    }
}

struct OperationRowView: View {
    let operation: Operation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let instrument = operation.instrument {
                TopView(instument: instrument)
            }
            HStack {
                leftStack
                Spacer()
                rightStack
            }
        }
    }

    var leftStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let type = operation.operationType {
                HStack(spacing: 2) {
                    Text(type.rawValue)
                    if operation.quantityExecuted > 0 {
                        Text(operation.quantityExecuted.string)
                        Text("шт")
                    }
                }

                .font(.system(size: 15, weight: .bold))
            }

            Text(DateFormatter.format("dd.MM.yy HH:mm").string(from: operation.date))
                .font(.system(size: 13))
        }
    }

    var rightStack: some View {
        VStack(alignment: .trailing, spacing: 2) {
            MoneyText(money: operation.money)

            if let commission = operation.commission {
                MoneyText(money: commission)
                    .foregroundColor(Color.gray)
            }
        }
        .font(.system(size: 14))
    }
}
