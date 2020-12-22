//
//  ContentView.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import CombineMoya
import InvestModels
import Moya
import SwiftUI

class OperationsObject: CancebleObservableObject {}

class MainViewModel: CancebleObservableObject {
    let accountService: AccountService
    let positionService: PositionsService
    let operationsService: OperationsService

    @ObservedObject var instrumentsStorage: InstrumentsStorage

    @Published var account: Account?
    @Published var operations: [Operation] = []
    @Published var positions: [Position] = []

    internal init(accountService: AccountService = .init(), positionService: PositionsService = .init(),
                  operationsService: OperationsService = .init(), instrumentsStorage: InstrumentsStorage = .init())
    {
        self.accountService = accountService
        self.positionService = positionService
        self.operationsService = operationsService
        self.instrumentsStorage = instrumentsStorage
    }

    public func loadData() {
//        loadAccount()
        loadPositions()
        loadOperaions()
    }

    public func loadAccount() {
        accountService.getBrokerAccount()
            .replaceError(with: nil)
            .assign(to: \.account, on: self)
            .store(in: &cancellables)
    }

    public func loadPositions() {
        positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)
    }

    public func loadOperaions() {
        let yearOld = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        operationsService
            .getOperations(request: OperationsService.OperationsRequest(from: yearOld, to: Date()))
            .receive(on: DispatchQueue.global())
            .replaceError(with: [])
            .combineLatest(instrumentsStorage.$instruments) { (operations, instruments) -> [Operation] in
                operations.map { operation -> Operation in // .filter { $0.figi != nil }
                    var newOperation = operation
                    newOperation.instument = instruments.first(where: { $0.figi == operation.figi })
                    return newOperation
                }
            }
            //            .print("getOperations")
            .receive(on: DispatchQueue.main)
            .assign(to: \.operations, on: self)
            .store(in: &cancellables)
    }
}

struct MainView: View {
    @EnvironmentObject var operationObject: OperationsObject
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        TabView {
            ViewFactory.homeView(mainViewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "dollarsign.circle")
                        Text("Profile")
                    }
                }
            ViewFactory.analyticsView(mainViewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Analytics")
                    }
                }

            ViewFactory.operationsView(mainViewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("Operations")
                    }
                }
        }.onAppear(perform: viewModel.loadData)
            .accentColor(Color(UIColor.systemOrange))
    }
}

// line.diagonal.arrow 􀫱
// slider.vertical.3 􀟲
//
