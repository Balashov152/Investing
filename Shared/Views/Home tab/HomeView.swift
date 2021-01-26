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

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var showingDetail = false

    @State var expandedSections = Set<InstrumentType>([.Stock])
    func isExpandedSection(type: InstrumentType) -> Binding<Bool> {
        .init { () -> Bool in
            expandedSections.contains(type)
        } set: { isExpand in
            if isExpand {
                expandedSections.insert(type)
            } else {
                expandedSections.remove(type)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                convertView
//                convertedExchangeRates
                list
            }
            .navigationBarItems(trailing: MainView.settingsNavigationLink)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var convertedExchangeRates: some View {
        Group {
            if let latest = viewModel.currencyPairServiceLatest.latest {
                HStack {
                    Text("USD")
                    Text((1 / latest.USD).formattedCurrency())

                    Text("EUR")
                    Text((1 / latest.EUR).formattedCurrency())
                }.padding()
            } else {
                Text("not avalible")
            }
        }
    }

    var currenciesInPositions: [Currency] {
        viewModel.positions.map { $0.currency }.unique.sorted(by: >)
    }

    var totalTitleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total profile")
                    .font(.largeTitle).bold()
                Spacer()
                if viewModel.convertType != .original {
                    Button(action: {
                        self.showingDetail.toggle()
                    }) {
                        Text("Full")
                    }.sheet(isPresented: $showingDetail) {
                        ViewFactory.totalDetailView
                    }.buttonStyle(PlainButtonStyle())
                }
            }

            switch viewModel.convertType {
            case .original:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(currenciesInPositions.indexed(), id: \.element) { index, currency in
                            if index != 0 { Divider() }
                            TotalView(model: TotalViewModel(currency: currency, positions: viewModel.positions))
                        }
                    }
                }
            case .currency:
                if let convertedTotal = viewModel.convertedTotal {
                    TotalView(model: convertedTotal)
                }
            }
        }.animation(.default)
    }

    var convertView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Text("Convert")
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
                    BackgroundButton(title: currency.rawValue, isSelected: viewModel.convertType == .currency(currency)) {
                        if viewModel.convertType == .currency(currency) {
                            viewModel.convertType = .original
                        } else {
                            viewModel.convertType = .currency(currency)
                        }
                    }
                }
            }.font(.system(size: 17, weight: .semibold))
        }
    }

    var list: some View {
        List {
            totalTitleView
            ForEach(viewModel.sections) { section in
                Section {
                    DisclosureGroup(isExpanded: isExpandedSection(type: section.type),
                                    content: {
                                        groupContent(section: section)
                                    },
                                    label: {
                                        HeaderView(section: section)
                                    })
                }
            }
        }
        .listStyle(GroupedListStyle())
    }

    func groupContent(section: HomeViewModel.Section) -> some View {
        ForEach(section.positions,
                id: \.self, content: { position in
                    PositionRowView(position: position)
                        .background(
                            NavigationLink(destination: ViewFactory.positionDetailView(position: position,
                                                                                       env: viewModel.env)) {
                                EmptyView()
                            }
                            .hidden()
                        )

                })
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
