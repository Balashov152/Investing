//
//  OperationsView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Foundation
import SwiftUI
import Combine
import Moya
import InvestModels

class OperationsViewModel: MainCommonViewModel {
    var operations: [Operation] {
        mainViewModel.operations
    }
}

struct OperationsView: View {
    @ObservedObject var viewModel: OperationsViewModel
    @State private var type = Operation.OperationTypeWithCommission.Buy
    
    var body: some View {
        NavigationView {
            List {
//                NavigationLink("Open Buy/Sell",
//                               destination: ViewFactory.balanceView())
                NavigationLink("Open Comission",
                               destination: ViewFactory.comissionView(mainViewModel: viewModel.mainViewModel))
                NavigationLink("Open Currency",
                               destination: ViewFactory.currencyView(mainViewModel: viewModel.mainViewModel))
                NavigationLink("Open Tickers",
                               destination: ViewFactory.tickersView(mainViewModel: viewModel.mainViewModel))
                
                segmentView
                operationsList
            }.navigationTitle("All Operations")
//            .onAppear(perform: viewModel.loadData)
        }
    }
    
    var segmentView: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Operation.OperationTypeWithCommission.allCases, id: \.self) { type in
                    Button<Text>(action: {
                        self.type = type
                    }, label: {
                        Text(type.rawValue)
                            .foregroundColor(Color.accentColor)
                    }).background(Color.black)
                }
            }
        }.frame(height: 50)
    }
    
    var operationsList: some View {
        Section(header: Text(type.rawValue)) {
            ForEach(viewModel.operations.filter { $0.operationType == type }, id: \.hashValue) {
                OperationRowView(operation: $0)
            }
        }
    }
}
