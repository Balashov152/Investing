//
//  PosotionInfoRow.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import SwiftUI

struct PosotionInfoRow: View {
    let label: String
    let changes: PositionDetailViewModel.ChangeOperation

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.system(size: 15))
                Text(changes.count.string + "pcs")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            CurrencyText(money: changes.money)
        }
    }
}
