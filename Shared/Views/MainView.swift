//
//  ContentView.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI
import Combine
import CombineMoya
import Moya
import InvestModels

class MainViewModel: CancebleObservableObject {
    let accountService: AccountService
    let positionService: PositionsService
    let operationsService: OperationsService
    
    @ObservedObject var instrumentsStorage: InstrumentsStorage
    
    @Published var account: Account?
    @Published var operations: [Operation] = []
    @Published var positions: [Position] = []
    
    internal init(accountService: AccountService, positionService: PositionsService,
                  operationsService: OperationsService, instrumentsStorage: InstrumentsStorage) {
        
        self.accountService = accountService
        self.positionService = positionService
        self.operationsService = operationsService
        self.instrumentsStorage = instrumentsStorage
    }
    
    public func loadData() {
        accountService.getBrokerAccount()
//            .print("getProfile")
            .replaceError(with: nil)
            .assign(to: \.account, on: self)
            .store(in: &cancellables)
        
        positionService.getPositions()
//            .map { $0.filter {$0.instrumentType != .some(.Currency) } }
//            .eraseToAnyPublisher()
            .print("getPositions")
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
        
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
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        TabView {
            ViewFactory.homeView(mainViewModel: viewModel)
             .tabItem {
                Image(systemName: "phone.fill")
                Text("First Tab")
              }
            ViewFactory.operationsView(mainViewModel: viewModel)
                 .tabItem {
                    Image(systemName: "tv.fill")
                    Text("Second Tab")
                  }
        }.onAppear(perform: viewModel.loadData)
    }
}
