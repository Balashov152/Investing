//
//  ComissionView.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Combine
import InvestModels
import SwiftUI

struct ComissionView: View {
    @ObservedObject var viewModel: ComissionViewModel

    var body: some View {
        List {
            ForEach(viewModel.rows, id: \.type) { row in
                MoneyRow(label: row.title, money: row.value)
            }
            if viewModel.total.value != 0 {
                MoneyRow(label: "Total".localized, money: viewModel.total)
            }
        }
        .navigationTitle("Commission".localized)
        .onAppear(perform: viewModel.loadOperaions)
    }
}
