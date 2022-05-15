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
                Section(header: YearHeaderView(section: section)) {
                    ForEach(section.months) { month in
                        RowDisclosureGroup(element: month, content: {
                            ForEach(month.operations) { operation in
                                MoneyRow(label: operation.localizedDate, money: operation.money)
                            }
                        }, label: {
                            HeaderView(section: month)
                        })
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Operations".localized)
        .onAppear(perform: viewModel.load)
    }

    struct HeaderView: View {
        let section: PayInViewModel.Month
        var body: some View {
            if let result = section.result {
                MoneyRow(label: section.header, money: result)
            }
        }
    }

    struct YearHeaderView: View {
        let section: PayInViewModel.Section
        var body: some View {
            HStack {
                Text(section.year.string).font(.title).bold()

                if let result = section.result {
                    Spacer()
                    MoneyText(money: result)
                        .body.font(.title3).bold()
                }
            }
        }
    }
}
