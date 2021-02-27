//
//  OperationsView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import InvestModels
import SwiftUI

struct OperationsView: View {
    @ObservedObject var viewModel: OperationsViewModel

    var operations: [Operation] {
        viewModel.operations.filter { $0.operationType == viewModel.selectedType }
    }

    var avalibleTypes: [Operation.OperationTypeWithCommission] {
        Operation.OperationTypeWithCommission.allCases.filter { type in
            viewModel.operations.contains(where: { $0.operationType == .some(type) })
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: segmentView) {
                    ForEach(operations, id: \.self) {
                        OperationRowView(operation: $0)
                    }
                }
            }
            .navigationTitle("Operations".localized)
            .onAppear(perform: viewModel.loadOperaions)
        }
    }

    var segmentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(avalibleTypes, id: \.self) { type in
                    Button(action: {
                        viewModel.selectedType = type
                    }, label: {
                        Text(type.rawValue)
                            .foregroundColor(Color.accentColor)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(viewModel.selectedType == .some(type) ? Color(UIColor.systemGray2) : Color.clear)
                            .cornerRadius(7)
                            .textCase(nil)
                    })
                }
            }
        }.frame(height: 40)
    }
}
