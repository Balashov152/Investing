//
//  PayInView.swift
//  Investing
//
//  Created by Sergey Balashov on 10.02.2021.
//

import Combine
import InvestModels
import SwiftUI

struct PayInView: View {
    @ObservedObject var viewModel: PayInViewModel

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                RowDisclosureGroup(element: section, content: {
                    ForEach(section.rows) { row in
                        HStack {
                            MoneyRow(label: row.localizedDate, money: row.money)
                        }
                    }
                }, label: {
                    HeaderView(section: section)
                })
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Operations".localized + " - " + viewModel.convertCurrency.rawValue)
        .onAppear(perform: viewModel.load)
    }

    struct HeaderView: View {
        let section: PayInViewModel.Section
        var body: some View {
            if let result = section.result {
                MoneyRow(label: section.header, money: result)
            }
        }
    }
}
