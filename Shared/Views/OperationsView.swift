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

class OperationsViewModel: ObservableObject {
    let operationsService = OperationsService()
    
    @ObservedObject var instrumentsStorage: InstrumentsStorage
    
    var operations: [Operation] {
        mainViewModel?.operations ?? []
    }
    
    var cancellables = Set<AnyCancellable>()
    
    weak var mainViewModel: MainViewModel?
    
    init(mainViewModel: MainViewModel, instrumentsStorage: InstrumentsStorage) {
        self.mainViewModel = mainViewModel
        self.instrumentsStorage = instrumentsStorage
    }
    
    public func loadData() {
        let yearOld = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        
        operationsService
            .getOperations(request: OperationsService.OperationsRequest(from: yearOld, to: Date()))
            .replaceError(with: [])
            .combineLatest(instrumentsStorage.$instruments, { (operations, instruments) -> [Operation] in
                operations.map { operation -> Operation in // .filter { $0.figi != nil }
                    var newOperation = operation
                    newOperation.instument = instruments.first(where: { $0.figi == operation.figi })
                    return newOperation
                }
            })
            //            .print("getOperations")
            .assign(to: \.operations, on: mainViewModel!)
            .store(in: &cancellables)
    }
}

struct OperationsView: View {
    @ObservedObject var viewModel: OperationsViewModel
    @State private var type = Operation.OperationTypeWithCommission.Buy
    
    func balanceView() -> BalanceView {
        .init(viewModel: .init(operations: viewModel.operations))
    }
    
    func comissionView() -> ComissionView {
        .init(viewModel: .init(operations: viewModel.operations))
    }
    
    func currencyView() -> CurrencyView {
        .init(viewModel: .init(operations: viewModel.operations))
    }
    
    func tickersView() -> TickersView {
        .init(viewModel: .init(operations: viewModel.operations, positions: viewModel.mainViewModel?.positions ?? []))
    }
    
    
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Open Buy/Sell",
                               destination: balanceView())
                NavigationLink("Open Comission",
                               destination: comissionView())
                NavigationLink("Open Currency",
                               destination: currencyView())
                NavigationLink("Open Tickers",
                               destination: tickersView())
                
                segmentView
                operationsList
            }.navigationTitle("All Operations")
            .onAppear(perform: viewModel.loadData)
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

struct OperationRowView: View {
    let operation: Operation
    var body: some View {
        VStack(alignment: .leading) {
            if let instument = operation.instument {
                HStack {
                    if let ticker = instument.ticker, let name = instument.name {
                        Text(name + " (\(ticker))").lineLimit(1)
                        
                    }
                }.font(.system(size: 17, weight: .semibold))
            }
            
            HStack {
                VStack(alignment: .leading) {
                    if let type = operation.operationType {
                        Text(type.rawValue + " " + operation.quantityExecuted.string + " " + operation.currency.rawValue)
                            .font(.system(size: 15, weight: .bold))
                    }
                    
                    if let date = operation.date {
                        Text(DateFormatter.format("dd.MM.yy HH:mm").string(from: date))
                            .font(.system(size: 13))
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if let payment = operation.payment, let currency = operation.currency {
                        Text(payment.format(f: ".2") + " " + currency.rawValue)
                    }
                    if let commission = operation.commission {
                        Text(commission.value.format(f: ".2") + " " + commission.currency.rawValue)
                            .foregroundColor(Color.gray)
                    }
                }.font(.system(size: 14))
            }
        }
    }
}
