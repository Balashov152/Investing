//
//  DividentsView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.12.2020.
//
import Combine
import InvestModels
import SwiftUI

struct DividentsView: View {
    @ObservedObject var viewModel: DividentsViewModel
    @State var expanded: Set<Instrument> = []

    var body: some View {
        List {
            Section {
                MoneyRow(label: "Total dividends".localized,
                         money: viewModel.dividents.filter(types: [.Coupon, .Dividend])
                             .currencySum(to: .RUB))

                MoneyRow(label: "Total tax".localized,
                         money: viewModel.dividents.filter(types: [.TaxCoupon, .TaxDividend])
                             .currencySum(to: .RUB))
            }

            Section {
                ForEach(viewModel.instruments, id: \.self) { instrument in
                    let operations = viewModel.dividents
                        .filter { $0.instrument == instrument }
                        .sorted(by: { $0.date < $1.date })

                    RowDisclosureGroup(element: instrument, content: {
                        ForEach(operations, id: \.self) { operation in
                            Row(operation: operation)
                        }
                    }, label: {
                        MoneyRow(label: instrument.name,
                                 money: operations.currencySum(to: instrument.currency))
                    })
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Dividends".localized)
        .onAppear(perform: viewModel.loadOperaions)
    }

    struct Row: View {
        let operation: Operation

        var body: some View {
            VStack(alignment: .leading) {
                CurrencyRow(label: operation.operationType.localized,
                            money: MoneyAmount(currency: operation.currency,
                                               value: operation.payment))
                Text(operation.date.string(format: "HH:mm dd MMMM yyyy"))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.gray)
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}

extension Operation.OperationTypeWithCommission {
    var localized: String {
        switch self {
        case .Coupon, .Dividend:
            return rawValue.capitalized.localized
        case .TaxCoupon:
            return "Coupon tax".localized
        case .TaxDividend:
            return "Dividend tax".localized
        default:
            return rawValue
        }
    }
}
