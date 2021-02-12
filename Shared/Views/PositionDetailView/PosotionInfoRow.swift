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
            Text(label)
            Spacer()
            CurrencyText(money: changes.money)
            Text(changes.count.string)
        }
    }
}
