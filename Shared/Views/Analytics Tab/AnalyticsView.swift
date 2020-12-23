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
                NavigationLink("Comission",
                               destination: ViewFactory.comissionView())
                NavigationLink("Currency",
                               destination: ViewFactory.currencyView())
                NavigationLink("Tickers",
                               destination: ViewFactory.tickersView())
            }.navigationTitle("Analytics")
        }
    }
}
