//
//  CurrencyTabView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 25.12.2020.
//

import Combine
import InvestModels
import Moya
import SwiftUI

class CurrencyTabViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var currencies: [CurrencyPair] = []

    let realmManager = RealmManager()

    public func loadPositions() {
        realmManager.syncQueueBlock {
            let objects = realmManager.objects(CurrencyPairR.self,
                                               sorted: [NSSortDescriptor(key: "date", ascending: false)])
                .map { CurrencyPair(currencyPairR: $0) }

            DispatchQueue.main.async {
                self.currencies = objects
            }
        }
    }
}

struct CurrencyTabView: View {
    @ObservedObject var viewModel: CurrencyTabViewModel

    var body: some View {
        NavigationView {
            List(viewModel.currencies, id: \.self) { section in
                HStack {
                    Text("id")
                    Text(CurrencyPair.dateFormatter.string(from: section.date))
                    Spacer()
                }
            }
            .onAppear(perform: viewModel.loadPositions)
        }
    }
}
