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

extension Collection {
    func enumeratedArray() -> [(offset: Int, element: Self.Element)] {
        return Array(enumerated())
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingPopover = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                convertView
                list
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var totalTitleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total profile")
                    .font(.largeTitle).bold()
            }.onTapGesture {
                isShowingPopover.toggle()
            }
            if isShowingPopover {
                ForEach(viewModel.positions.map { $0.currency }.unique.sorted(by: >).enumeratedArray(), id: \.element) { index, currency in
                    if index != 0 {
                        Divider()
                    }
                    TotalView(currency: currency, positions: viewModel.positions)
                }
            }
        }.animation(.linear)
    }

    var convertView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Text("Convert positions")
                        .font(.system(size: 20, weight: .medium))
                    Spacer(minLength: 16)
                    segment
                }
            }.padding()

            Divider()
        }
    }

    var segment: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.positions.map { $0.currency }.unique.sorted(by: >), id: \.self) { currency in
                    BackgroundButton(title: currency.rawValue, isSelected: viewModel.currency == .currency(currency)) {
                        if viewModel.currency == .currency(currency) {
                            viewModel.currency = .original
                        } else {
                            viewModel.currency = .currency(currency)
                        }
                    }
                }
            }.font(.system(size: 17, weight: .semibold))
        }
    }

    var list: some View {
        List {
            totalTitleView
            ForEach(viewModel.sections, id: \.self) { section in
                Section {
                    PlainSection(header: HeaderView(section: section)) {
                        ForEach(section.positions,
                                id: \.self, content: PositionRowView.init)
                    }
                }
            }
        }.listStyle(GroupedListStyle())
    }

    var currencies: some View {
        Section {
            PlainSection(header: HeaderView(section: .init(type: .Currency, positions: []))) {
                ForEach(viewModel.currencies, id: \.self) { currency in
                    HStack {
                        Text(currency.currency.rawValue)
                        Spacer()
                        MoneyText(money: .init(currency: currency.currency, value: currency.balance))
                    }
                }
            }
        }
    }
}

struct BackgroundButton: View {
    let title: String
    let isSelected: Bool

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isSelected ? Color.white : Color.accentColor)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background(isSelected ? Color.accentColor : Color(UIColor.litleGray))
                .cornerRadius(6)
                .textCase(nil)
        }
    }
}

extension HomeView {
    struct TotalView: View {
        let currency: Currency
        let positions: [Position]

        var filteredPositions: [Position] {
            positions.filter { $0.currency == currency }
        }

        var totalInProfile: MoneyAmount {
            MoneyAmount(currency: currency, value: filteredPositions.map { $0.totalInProfile }.sum)
        }

        var expectedProfile: MoneyAmount {
            MoneyAmount(currency: currency, value: filteredPositions.map { $0.expectedYield }.sum)
        }

        var body: some View {
            HStack {
                CurrencyText(money: totalInProfile)
                MoneyText(money: expectedProfile)
            }
        }
    }

    struct HeaderView: View {
        let section: HomeViewModel.Section

        var body: some View {
            HStack {
                Text(section.type.rawValue)
                    .font(.system(size: 20, weight: .bold))
                    .textCase(.uppercase)
                Spacer()
                HStack {
                    ForEach(section.currencies, id: \.self) { currency in
                        if section.sum(currency: currency) > 0 {
                            MoneyText(money: MoneyAmount(currency: currency,
                                                         value: section.sum(currency: currency)))
                                .font(.system(size: 20, weight: .regular))
                        }
                    }
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
