//
//  AnalyticsView.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import SwiftUI

class AnalyticsViewModel: EnvironmentCancebleObject, ObservableObject {}

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Commission".localized,
                               destination: ViewFactory.comissionView)
                NavigationLink("Currency".localized,
                               destination: ViewFactory.currencyView)
                NavigationLink("Results on investment".localized,
                               destination: ViewFactory.tickersView)
                NavigationLink("Dividends".localized,
                               destination: ViewFactory.dividentsView)
                NavigationLink("Deposit operations".localized,
                               destination: ViewFactory.payInView)
                NavigationLink("Plans pay in",
                               destination: ViewFactory.plansPayInView)
            }
            .listStyle(GroupedListStyle())
            .navigationBarItems(trailing: MainView.settingsNavigationLink)
            .navigationTitle("Analytics".localized)
        }
    }
}
