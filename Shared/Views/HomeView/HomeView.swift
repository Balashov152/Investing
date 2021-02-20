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
    @State var expandedSections: Set<InstrumentType> {
        willSet {
            viewModel.env.settings.expandedHome = newValue
        }
    }

    init(viewModel: HomeViewModel) {
        _expandedSections = .init(initialValue: viewModel.env.settings.expandedHome)

        self.viewModel = viewModel
    }

    func isExpandedSection(type: InstrumentType) -> Binding<Bool> {
        .init {
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
            list
                .navigationBarItems(trailing: MainView.settingsNavigationLink)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear(perform: viewModel.loadPositions)
        }
    }

    // MARK: Positions View

    var list: some View {
        ScrollView {
            HomeHeaderTotalView(viewModel: viewModel)
            ForEach(viewModel.sections) { section in
                DisclosureGroup(isExpanded: isExpandedSection(type: section.type),
                                content: {
                                    groupContent(section: section)
                                },
                                label: {
                                    HomeHeaderView(section: section)
                                })
                Divider()
            }
            .padding([.leading, .trailing], 16)
        }
    }

    func groupContent(section: HomeViewModel.Section) -> some View {
        ForEach(section.positions.indexed(), id: \.element, content: { index, position in
            if index == 0 {
                Divider()
            } else {
                Divider().padding(.leading, 10)
            }

            switch position.instrumentType {
            case .Stock, .Bond, .Etf:
                NavigationLink(destination: NavigationLazyView(ViewFactory.positionDetailView(position: position,
                                                                                              env: viewModel.env))) {
                    PositionRowView(position: position)
                        .padding(.leading, 10)
                }
            case .Currency:
                CurrencyPositionRowView(position: position)
            }
        })
    }

    var currencies: some View {
        Section {
            PlainSection(header: HomeHeaderView(section: .init(type: .Currency, positions: []))) {
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
