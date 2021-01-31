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
import UIKit

extension TargetsViewModel {
    struct Column: Hashable, Identifiable {
        let percent: Double
        var percentVisible: Double { percent * 100 }
        let target: Double
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

    @State var sliderValue = 0.5

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
                            ColumnView(column: column, height: height * multiplicator, changeTarget: $sliderValue)
                        }
                    }
                }.frame(height: height, alignment: .bottom)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                List {
//                Section {
//                }

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

    struct ColumnView: View {
        let column: TargetsViewModel.Column
        let height: CGFloat
        let changeTarget: Binding<Double>

        var body: some View {
            VStack {
                Spacer()
                if let isin = column.position.isin {
                    URLImage(url: LogoService.logoUrl(for: isin)) { image in
                        image
                            .frame(width: 15, height: 15)
                            .cornerRadius(7.5)
                    }
                }
                Rectangle()
                    .foregroundColor(Color(UIColor.systemBlue))
                    .frame(width: 15,
                           height: height * CGFloat(column.percent), alignment: .bottom)
                    .cornerRadius(3)

                Slider(value: changeTarget, in: 0 ... 1)
                    .frame(width: height, height: 10)
                    .rotationEffect(Angle(degrees: -90), anchor: .topLeading)
                    .offset(y: height)
                    .zIndex(1.0)
                    .introspectSlider { slider in
                        slider.setThumbImage(UIImage(systemName: "poweron"), for: .normal)
                    }
                    .background(Color.red)

                Text(column.percentVisible.string(f: ".2") + "%")
                    .font(.system(size: 8, weight: .light))
            }
        }
    }
}
