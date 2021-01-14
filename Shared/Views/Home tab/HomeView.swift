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
    enum ConvertedType {
        case original
        case currency(Currency)

        var localize: String {
            switch self {
            case let .currency(currency):
                return "in " + currency.rawValue
            case .original:
                return "orignal"
            }
        }
    }
}

class HomeViewModel: EnvironmentCancebleObject, ObservableObject {
    struct Section: Hashable {
        let type: InstrumentType
        let positions: [Position]
        let currencies: [CurrencyPosition]
    }

    @Published var currency: ConvertedType = .original

    @Published var sections: [Section] = []
    @Published var positions: [Position] = []
    @Published var currencies: [CurrencyPosition] = []

    var timer: Timer?

    override func bindings() {
        Publishers.CombineLatest($positions.dropFirst(), $currencies.dropFirst())
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

        startTimer()
    }

    public func loadPositions() {
        env.positionService.getPositions()
            .replaceError(with: [])
            .assign(to: \.positions, on: self)
            .store(in: &cancellables)

        env.positionService.getCurrences()
            .replaceError(with: [])
            .assign(to: \.currencies, on: self)
            .store(in: &cancellables)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [unowned self] _ in
            loadPositions()
        })
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

                ForEach(viewModel.currencies, id: \.self) { currency in
                    HStack {
                        Text(currency.currency.rawValue)
                        Spacer()
                        MoneyText(money: .init(currency: currency.currency, value: currency.balance))
                    }
                }
            }

            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
            .listSeparatorStyle(style: .none)
            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var segment: some View {
        HStack {
            ForEach(Currency.allCases, id: \.self) { currency in
                Button(currency.rawValue) {
                    viewModel.currency = .currency(currency)
                }
            }
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
                Text(section.type.rawValue + "s")
                    .font(.system(size: 20, weight: .bold))
                    .textCase(.uppercase)
                Spacer()
                Text(alpha.string(f: ".2"))
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.currency(value: alpha))
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
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
