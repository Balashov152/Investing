//
//  BalanceView.swift
//  Investing
//
//  Created by Sergey Balashov on 09.12.2020.
//

import Foundation
import SwiftUI
import Combine

struct GroupedDateOperations {
    let date: Date
    let operations: [Operation]
    
    var sumBuy: Double {
        operations.filter {$0.operationType == .some(.Buy) } .reduce(0, { $0 + ($1.payment ?? 0) })
    }
    var sumSell: Double {
        operations.filter {$0.operationType == .some(.Sell) }.reduce(0, { $0 + ($1.payment ?? 0) })
    }
}

class BalanceViewModel: ObservableObject {
    @Published var operations: [Operation] = []
    @Published var groupedOperations: [GroupedDateOperations] = []
    @Published var balance: Double = 0.0
    
    var cancellables = Set<AnyCancellable>()
    
    init(operations: [Operation]) {
        self.operations = operations
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.groupedOperations = Dictionary(grouping: operations, by: { (operation) -> Date in
                let calendar = Calendar.current
                let month = calendar.dateComponents([.month], from: operation.date)
                return calendar.date(from: month) ?? operation.date
            }).sorted(by: { $0.key > $1.key })
            .map { key, values -> GroupedDateOperations in
                GroupedDateOperations(date: key, operations: values)
            }
            
//            let addUSDSum = operations.filter { $0.operationType == .some(.PayIn) && $0.currency == .USD }.sum
//            let buyUSDSumm = operations.filter { $0.operationType == .some(.Buy) && $0.currency == .USD && $0.instrumentType == .some(.Currency) }.sum
            
            let sumBuy = operations.filter {$0.operationType == .some(.Buy) }.sum
            let sumSell = operations.filter {$0.operationType == .some(.Sell) }.sum
            self.balance = sumSell - abs(sumBuy)
        }
    }
}

extension Collection where Element == Operation {
    var sum: Double {
        map { $0.payment }.reduce(0, +)
    }
}

extension Collection where Element == MoneyAmount {
    var sum: Double {
        map { $0.value }.reduce(0, +)
    }
}

extension Collection where Element == Double {
    var sum: Double {
        reduce(0, +)
    }
}

struct BalanceView: View {
    @ObservedObject var viewModel: BalanceViewModel

    var body: some View {
            List {
                Text(viewModel.balance.format(f: ".2"))
                    .font(.headline)
                
                ForEach(viewModel.groupedOperations, id: \.date) { groupe in
                    Section(header: SectionHeader(groupeSection: groupe)) {
                        ForEach(groupe.operations, id: \.date) { operation in
                            OperationRowView(operation: operation)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("All Operations \(viewModel.groupedOperations.count)")
    }
}

struct SectionHeader: View {
    let groupeSection: GroupedDateOperations
    var body: some View {
        HStack {
            Text(DateFormatter.format("LLLL").string(from: groupeSection.date).lowercased()).font(.title)
            Spacer()
            VStack {
                Text(groupeSection.sumBuy.format(f: ".2")).foregroundColor(.red)
                Text(groupeSection.sumSell.format(f: ".2")).foregroundColor(.green)
            }.font(.system(size: 12))
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .background(Color.white)
    }
}

extension DateFormatter {
    
    static func format(_ string: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        return formatter
    }
    
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
