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

extension HomeViewModel {
    enum ConvertedType: Equatable {
        case original
        case currency(Currency)

        var localize: String {
            switch self {
            case let .currency(currency):
                return currency.rawValue
            case .original:
                return "orignal"
            }
        }
    }
}

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    struct Section: Hashable {
        let type: InstrumentType
        let positions: [PositionView]
    }

    let currencyPairServiceLatest: CurrencyPairServiceLatest

    @Published var currency: ConvertedType = .original

    @Published var sections: [Section] = []
    @Published var positions: [Position] = []
    @Published var currencies: [CurrencyPosition] = []

    override init(env: Environment = .current) {
        currencyPairServiceLatest = CurrencyPairServiceLatest(env: env)

        super.init(env: env)
    }

    var timer: Timer?

    override func bindings() {
        Publishers.CombineLatest($positions.dropFirst(), $currency.removeDuplicates())
            .receive(on: DispatchQueue.global())
            .map { [unowned self] positions, currencyType -> [PositionView] in
                self.map(positions: positions, to: currencyType)
            }
            .map { positions -> [Section] in
                [InstrumentType.Stock, .Bond, .Etf].compactMap { type -> Section? in
                    let filtered = positions
                        .filter { $0.instrumentType == .some(type) }
                        .sorted { $0.name.orEmpty < $1.name.orEmpty }
                    if !filtered.isEmpty {
                        return Section(type: type, positions: filtered)
                    }
                    return nil
                }
            }.receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)

//        startTimer()
    }

    public func loadPositions() {
        env.api().positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)

        env.api().positionService.getCurrences()
            .replaceError(with: [])
            .assign(to: \.currencies, on: self)
            .store(in: &cancellables)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [unowned self] _ in
            loadPositions()
        })
    }

    private func map(positions: [Position], to currencyType: ConvertedType) -> [PositionView] {
        switch currencyType {
        case let .currency(currency):
            return positions.map { position -> PositionView in
                PositionView(position: position,
                             expectedYield: CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                           money: position.expectedYield,
                                                                           to: currency),
                             averagePositionPrice: CurrencyConvertManager.convert(currencyPair: currencyPairServiceLatest.latest,
                                                                                  money: position.averagePositionPrice,
                                                                                  to: currency))
            }
        case .original:
            return positions.map { position -> PositionView in
                PositionView(position: position)
            }
        }
    }
}

struct PlainSection<Header: View, Content: View>: View {
    let header: Header
    let content: () -> Content

    var body: some View {
        header
        content()
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingPopover = false

    var body: some View {
        NavigationView {
            List {
                topView
                if isShowingPopover {
                    segment
                }

                ForEach(viewModel.sections, id: \.self) { section in
                    Section {
                        PlainSection(header: HeaderView(section: section)) {
                            ForEach(section.positions,
                                    id: \.self, content: PositionRowView.init)
                        }
                    }
                }

//                if !viewModel.positions.isEmpty {
//                    Section {
//                        PlainSection(header: HeaderView(section: .init(type: .Currency, positions: []))) {
//                            ForEach(viewModel.currencies, id: \.self) { currency in
//                                HStack {
//                                    Text(currency.currency.rawValue)
//                                    Spacer()
//                                    MoneyText(money: .init(currency: currency.currency, value: currency.balance))
//                                }
//                            }
//                        }
//                    }
//                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
            .listSeparatorStyle(style: .none)
            .onAppear(perform: viewModel.loadPositions)
            .navigationBarItems(trailing: Button("Edit", action: {}))
        }
    }

    var segment: some View {
        ScrollView {
            HStack {
                ForEach(viewModel.positions.map { $0.currency }.unique.sorted(by: >), id: \.self) { currency in
                    Button(currency.rawValue) {
                        viewModel.currency = .currency(currency)
                    }
                }
            }.frame(height: 40, alignment: .leading)
        }
    }

    var topView: some View {
        HStack {
            Text("Profile in")
            Button(viewModel.currency.localize) {
                isShowingPopover.toggle()
            }
        }
        .textCase(.uppercase)
        .font(.system(size: 24, weight: .bold))
    }

    struct HeaderView: View {
        let section: HomeViewModel.Section

        var alpha: Double {
            section.positions.reduce(0) { $0 + $1.totalInProfile.value } - section.positions.reduce(0) { $0 + $1.totalBuyPayment.value }
        }

        var body: some View {
            HStack {
                Text(section.type.rawValue)
                    .font(.system(size: 20, weight: .bold))
                    .textCase(.uppercase)
                Spacer()
                if alpha > 0 {
                    Text(alpha.string(f: ".2"))
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.currency(value: alpha))
                }
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
    }
}

extension Array where Element: Hashable {
    var unique: [Element] {
        Array(Set(self))
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

struct ListSeparatorStyle: ViewModifier {
    let style: UITableViewCell.SeparatorStyle

    func body(content: Content) -> some View {
        content
            .onAppear {
                UITableView.appearance().separatorStyle = self.style
            }
    }
}

extension View {
    func listSeparatorStyle(style: UITableViewCell.SeparatorStyle) -> some View {
        ModifiedContent(content: self, modifier: ListSeparatorStyle(style: style))
    }
}
