//
//  OperationRowView.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import SwiftUI
import Combine

struct OperationRowView: View {
    let operation: Operation
    var body: some View {
        VStack(alignment: .leading) {
            if let instument = operation.instument {
                HStack {
                    if let ticker = instument.ticker, let name = instument.name {
                        Text(name + " (\(ticker))").lineLimit(1)
                        
                    }
                }.font(.system(size: 17, weight: .semibold))
            }
            Spacer()
            rightStack
        }
    }

    var rightStack: some View {
        HStack {
            VStack(alignment: .leading) {
                if let type = operation.operationType {
                    Text(type.rawValue + " " + operation.quantityExecuted.string + " " + operation.currency.rawValue)
                        .font(.system(size: 15, weight: .bold))
                }
                
                if let date = operation.date {
                    Text(DateFormatter.format("dd.MM.yy HH:mm").string(from: date))
                        .font(.system(size: 13))
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                if let payment = operation.payment, let currency = operation.currency {
                    Text(payment.string(f: ".2") + " " + currency.rawValue)
                }
                if let commission = operation.commission {
                    Text(commission.value.string(f: ".2") + " " + commission.currency.rawValue)
                        .foregroundColor(Color.gray)
                }
            }.font(.system(size: 14))
        }

    }
}
