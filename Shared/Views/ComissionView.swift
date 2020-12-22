//
//  ComissionView.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Combine
import SwiftUI

class ComissionViewModel: MainCommonViewModel {
    var operations: [Operation] {
        mainViewModel.operations
    }
}

struct ComissionView: View {
    @StateObject var viewModel: ComissionViewModel
    let commissionTypes = [Operation.OperationTypeWithCommission.BrokerCommission,
                           .ExchangeCommission, .ServiceCommission, .MarginCommission, .OtherCommission]

    var body: some View {
        List(commissionTypes, id: \.self) { type in
            switch type {
            case .BrokerCommission, .ServiceCommission, .MarginCommission:
                commisionCell(label: type.rawValue,
                              double: viewModel.operations.filter { $0.operationType == .some(type) }.sum)
            case .ExchangeCommission, .OtherCommission:
                commisionCell(label: type.rawValue,
                              double: viewModel.operations
                                  .filter { $0.operationType == .some(type) }
                                  .compactMap { $0.commission }.sum)
            default:
                Text("Not implement")
            }
        }.navigationTitle("Commissions")
    }

    func commisionCell(label: String, double: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(double.string(f: ".2"))
        }
    }
}
