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

    init(viewModel: HomeViewModel) {
        debugPrint("viewModel.env.settings.expandedHome", viewModel.env.settings.expandedHome)
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
                                   expanded: viewModel.env.settings.expandedHome,
                                   expandedChanged: { viewModel.env.settings.expandedHome = $0 },
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
}
