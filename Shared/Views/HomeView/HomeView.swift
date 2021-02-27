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

extension NotificationCenter {
    static var enterForeground: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isRefresh: Bool = false

    @State var expandedSections: Set<InstrumentType> {
        willSet {
            viewModel.env.settings.expandedHome = newValue
        }
    }

    init(viewModel: HomeViewModel) {
        _expandedSections = .init(initialValue: viewModel.env.settings.expandedHome)

        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            list
                .navigationBarItems(trailing: MainView.settingsNavigationLink)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear(perform: viewModel.loadPositions)
                .onReceive(NotificationCenter.enterForeground, perform: { _ in
                    viewModel.loadPositions()
                })
        }
    }

    // MARK: Positions View

    var list: some View {
        ScrollView {
            HomeHeaderTotalView(viewModel: viewModel)
            ForEach(viewModel.sections) { section in
                RowDisclosureGroup(element: section.type,
                                   expanded: expandedSections,
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
                NavigationLink(destination: NavigationLazyView(ViewFactory.detailCurrencyView(currency: position.currency,
                                                                                              operations: viewModel.currencyOperation(currency: position.currency),
                                                                                              env: viewModel.env))) {
                    CurrencyPositionRowView(position: position)
                        .padding(.leading, 10)
                }
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
