//
//  OperationsView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import Foundation
import InvestModels
import Moya
import SwiftUI

class OperationsViewModel: MainCommonViewModel {
//    var operations: [Operation] {
//        mainViewModel.operations
//    }

    override init(mainViewModel: MainViewModel) {
        super.init(mainViewModel: mainViewModel)
        mainViewModel.$operations.sink { _ in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }
}

struct OperationsView: View {
    @ObservedObject var viewModel: OperationsViewModel
    @State var type = Operation.OperationTypeWithCommission.Buy

    var operations: [Operation] {
        viewModel.mainViewModel.operations.filter { $0.operationType == type }
    }

    var avalibleTypes: [Operation.OperationTypeWithCommission] {
        Operation.OperationTypeWithCommission.allCases.filter { type in
            viewModel.mainViewModel.operations.contains(where: { $0.operationType == .some(type) })
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
            .navigationTitle("Operations")
        }
    }

    var segmentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(avalibleTypes, id: \.self) { type in
                    Button(action: {
                        self.type = type
                    }, label: {
                        Text(type.rawValue)
                            .foregroundColor(Color(UIColor.systemOrange))
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(self.type == .some(type) ? Color(UIColor.systemGray2) : Color.clear)
                            .cornerRadius(7)
                            .textCase(nil)
                    })
                }
            }
        }.frame(height: 40)
    }
}
