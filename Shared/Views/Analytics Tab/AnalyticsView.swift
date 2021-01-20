//
//  AnalyticsView.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

class AnalyticsViewModel: EnvironmentCancebleObject, ObservableObject {}

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Comission",
                               destination: NavigationLazyView(ViewFactory.comissionView))
                NavigationLink("Currency",
                               destination: ViewFactory.currencyView)
                NavigationLink("Tickers",
                               destination: ViewFactory.tickersView)
                NavigationLink("Dividends",
                               destination: ViewFactory.dividentsView)
            }.navigationTitle("Analytics")
        }
    }
}
