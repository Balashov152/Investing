//
//  AnalyticsView.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import SwiftUI

class AnalyticsViewModel: MainCommonViewModel {}

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Comission",
                               destination: ViewFactory.comissionView(mainViewModel: viewModel.mainViewModel))
                NavigationLink("Currency",
                               destination: ViewFactory.currencyView(mainViewModel: viewModel.mainViewModel))
                NavigationLink("Tickers",
                               destination: ViewFactory.tickersView(mainViewModel: viewModel.mainViewModel))
            }.navigationTitle("Analytics")
        }
    }
}
