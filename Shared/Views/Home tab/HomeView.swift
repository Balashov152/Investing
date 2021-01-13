//
//  HomeView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import InvestModels
import Moya
import SwiftUI

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    struct Section: Hashable {
        let type: InstrumentType
        let positions: [Position]
        let currencies: [CurrencyPosition]
    }

    @Published var sections: [Section] = []
    @Published var positions: [Position] = []
    @Published var currencies: [CurrencyPosition] = []

    public func loadPositions() {
        Publishers.CombineLatest($positions, $currencies)
            .receive(on: DispatchQueue.global())
            .map { positions, _ -> [Section] in
                [InstrumentType.Stock, .Bond, .Etf].compactMap { type -> Section? in
                    let filtered = positions
                        .filter { $0.instrumentType == .some(type) }
                        .sorted { $0.name.orEmpty < $1.name.orEmpty }
                    if !filtered.isEmpty {
                        return Section(type: type, positions: filtered, currencies: [])
                    }
                    return nil
                }
            }.receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)

        env.positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)

        env.positionService.getCurrences()
            .replaceError(with: [])
            .assign(to: \.currencies, on: self)
            .store(in: &cancellables)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections, id: \.type) { section in
                    Section(header: HeaderView(section: section)) {
                        ForEach(section.positions,
                                id: \.self, content: PositionRowView.init)
                    }
                }

                ForEach(viewModel.currencies, id: \.self) { currency in
                    HStack {
                        Text(currency.currency.rawValue)
                        Spacer()
                        MoneyText(money: .init(currency: currency.currency, value: currency.balance))
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile")
            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var topView: some View {
        Text("")
    }

    struct HeaderView: View {
        let section: HomeViewModel.Section

        var alpha: Double {
            section.positions.reduce(0) { $0 + $1.totalInProfile } - section.positions.reduce(0) { $0 + $1.totalBuyPayment }
        }

        var body: some View {
            HStack {
                Text(section.type.rawValue)
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text(alpha.string(f: ".2"))
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.currency(value: alpha))
            }
        }
    }
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

extension Color {
    static func currency(value: Double) -> Color {
        if value == .zero { return .gray }

        return value > 0 ? .green : .red
    }
}
