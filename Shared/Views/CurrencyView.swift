//
//  CurrencyView.swift
//  Investing
//
//  Created by Sergey Balashov on 11.12.2020.
//

import SwiftUI
import Combine

class CurrencyViewModel: MainCommonViewModel {
    @Published var buyUSD: Double = 0
    @Published var inUSD: Double = 0
    @Published var outUSD: Double = 0
    
    @Published var inRUB: Double = 0
    @Published var outRUB: Double = 0
    
    var operations: [Operation] {
        mainViewModel.operations
    }
    
    let filterBuyUsd: ((Operation) -> Bool) = {
        $0.instument?.currency == .some(.RUB) &&
        $0.instument?.type == .some(.Currency) &&
        $0.operationType == .some(.Buy) &&
        $0.currency == .RUB
    }
    
    override init(mainViewModel: MainViewModel) {
        super.init(mainViewModel: mainViewModel)
        
        mainViewModel.$operations
            .map { $0.filter { $0.operationType == .some(.PayIn) && $0.currency == .USD }.sum }
            .assign(to: \.inUSD, on: self).store(in: &cancellables)    
    }
    
    func loadView() {
        _buyUSD = .init(wrappedValue: Double(operations.filter(filterBuyUsd).reduce(0) { $0 + $1.quantityExecuted }))
//        inUSD = operations.filter { $0.operationType == .some(.PayIn) && $0.currency == .USD }.sum
        outUSD = operations.filter { $0.operationType == .some(.PayOut) && $0.currency == .USD }.sum
        
        inRUB = operations.filter { $0.operationType == .some(.PayIn) && $0.currency == .RUB }.sum
        outRUB = operations.filter { $0.operationType == .some(.PayOut) && $0.currency == .RUB }.sum
        outRUB = operations.filter { $0.operationType == .some(.PayOut) && $0.currency == .RUB }.sum
    }
}

struct CurrencyView: View {
    @StateObject var viewModel: CurrencyViewModel
    let commissionTypes = [Operation.OperationTypeWithCommission.Buy, .PayIn]
    
    var body: some View {
        List{
            Text("USD").font(.title)
            commisionCell(label: "Pay in USD", double: viewModel.inUSD)
            commisionCell(label: "Pay out USD", double: viewModel.outUSD)
            commisionCell(label: "All Buy USD", double: viewModel.buyUSD)
            commisionCell(label: "Total USD", double: viewModel.inUSD + viewModel.buyUSD + viewModel.outUSD)
            
            Text("RUB").font(.title)
            commisionCell(label: "Pay in RUB", double: viewModel.inRUB)
            commisionCell(label: "Pay out RUB", double: viewModel.outRUB)
            commisionCell(label: "Total RUB", double: viewModel.inRUB + viewModel.outRUB)
            
//            ForEach(viewModel.operations.filter(viewModel.filterBuyUsd), id: \.self) {
//                Text("tradersCount - \($0.tradersCount) quantityExecuted - \($0.quantityExecuted)")
//            }
            
        }.navigationTitle("Currency")
        .onAppear(perform: viewModel.loadView)
    }

    func commisionCell(label: String, double: Double) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(double.string(f: ".2"))
        }
    }
}
