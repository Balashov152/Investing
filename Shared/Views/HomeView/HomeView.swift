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

    @State private var isRefresh: Bool = false

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            list
                .navigationBarItems(trailing: MainView.settingsNavigationLink)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear(perform: viewModel.loadPositions)
                .onAppear(perform: {
                    UINavigationBar.appearance().shadowImage = UIImage()
                })
                .onReceive(NotificationCenter.enterForeground, perform: { _ in
                    viewModel.loadPositions()
                })
        }
    }

    // MARK: Positions View

    var list: some View {
        ScrollView {
            ShadowView {
                HomeHeaderTotalView(viewModel: viewModel)
            }

            ShadowView {
                VStack {
                    ForEach(viewModel.sections) { section in
                        RowDisclosureGroup(element: section.type,
                                           expanded: viewModel.env.settings.expandedHome,
                                           expandedChanged: { viewModel.env.settings.expandedHome = $0 },
                                           content: { groupContent(section: section) },
                                           label: { HomeHeaderView(section: section) })
                        if viewModel.sections.last != section {
                            Divider()
                        }
                    }
                }
                .padding(.all, 16)
            }
        }
    }

    @ViewBuilder
    func groupContent(section: HomeViewModel.Section) -> some View {
        let padding: CGFloat = 10
        ForEach(section.positions.indexed(), id: \.element, content: { index, position in
            if index == 0 {
                Divider()
            } else {
                Divider().padding(.leading, padding)
            }

            switch position.instrumentType {
            case .Stock, .Bond, .Etf:
                NavigationLink(destination: NavigationLazyView(ViewFactory.positionDetailView(position: position,
                                                                                              env: viewModel.env))) {
                    PositionRowView(position: position)
                        .padding(.leading, padding)
                }
            case .Currency:
                NavigationLink(destination: NavigationLazyView(ViewFactory.detailCurrencyView(currency: position.currency,
                                                                                              operations: viewModel.currencyOperation(currency: position.currency),
                                                                                              env: viewModel.env))) {
                    CurrencyPositionRowView(position: position)
                        .padding(.leading, padding)
                }
            }
        })
    }
}
