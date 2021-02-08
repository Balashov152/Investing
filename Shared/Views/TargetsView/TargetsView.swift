//
//  TargetsView.swift
//  Investing
//
//  Created by Sergey Balashov on 28.01.2021.
//

import Combine
import InvestModels
import Moya
import SwiftUI

extension TargetsViewModel {
    struct Column: Hashable, Identifiable {
        let percent: Double
        var percentVisible: Double { percent * 100 }
        var target: Double
        let position: Position
    }
}

extension CurrencyPosition {
    var money: MoneyAmount {
        .init(currency: currency, value: balance)
    }
}

class TargetsViewModel: EnvironmentCancebleObject, ObservableObject {
    var currencyPairServiceLatest: CurrencyPairServiceLatest { .shared }

    @Published var columns: [Column] = []
    var curency: Currency {
        env.settings.currency ?? .RUB
    }

    var total: Double {
        let total = env.api().positionService.positions.reduce(0) { result, position in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: position.totalInProfile,
                                                    to: curency).value
        } + env.api().positionService.currencies.reduce(0) { result, currency in
            result + CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                    money: currency.money,
                                                    to: curency).value
        }
//        debugPrint("total", total)
        return total
    }

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest(env.api().positionService.$positions,
                                 env.api().positionService.$currencies)
            .receive(on: DispatchQueue.global())
            .map { positions, _ -> [Column] in
                positions.compactMap { [unowned self] (position) -> Column? in
                    let convert = CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                 money: position.totalInProfile,
                                                                 to: curency).value
                    return Column(percent: convert / total,
                                  target: 0.8,
                                  position: position)
                }.sorted(by: { $0.percent > $1.percent })
            }
//            .print("targets")
            .receive(on: DispatchQueue.main)
            .assign(to: \.columns, on: self)
            .store(in: &cancellables)
    }

    public func load() {
        env.api().positionService.getPositions()
        env.api().positionService.getCurrences()
    }
}

struct TargetsView: View {
    @ObservedObject var viewModel: TargetsViewModel
    @State var showingDetail = false
    @State var showingRates = false
        
    func targetChange(coloumn: TargetsViewModel.Column) -> Binding<Double> {
        .init { () -> Double in
            viewModel.columns.first(where: { $0 == coloumn })?.target ?? 0
        } set: { (newValue) in
            viewModel.columns.first(where: { $0 == coloumn })?.target = newValue
        }

    }
    
    let height: CGFloat = UIScreen.main.bounds.height * 0.2
    var multiplicator: CGFloat {
        (viewModel.columns.map { $0.percent }.max() ?? 0) > 0.5 ? 1 : 2
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom) {
                        ForEach(viewModel.columns) { column in
                            ColumnView(column: column,
                                       mainSize: CGSize(width: 20, height: height * multiplicator),
                                       changeTarget: targetChange(coloumn: column))
                        }
                    }
                }
                .frame(height: height, alignment: .bottom)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                List {
                    PlainSection(header: Text("Positions").bold().font(.title).padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))) {
                        ForEach(viewModel.columns) {
                            InfoRow(label: $0.position.name.orEmpty, text: $0.percentVisible.string(f: ".5"))
                        }
                    }
                }
            }
            .navigationTitle("Targets")
//            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.load)
        }
    }
}

public func range<E: Comparable>(min: E, element: E, max: E) -> E {
    return Swift.min(Swift.max(min, element), max)
}
