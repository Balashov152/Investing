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

class SettingsTabViewModel: EnvironmentCancebleObject, ObservableObject {
    @State var token: String = Settings.shared.apiToken

    override func bindings() {
        super.bindings()

//        $token.publisher.print()

//            .assign(to: \.operations, on: self)
//            .store(in: &cancellables)
    }

//    public func loadPositions() {
//        realmManager.syncQueueBlock {
//            let objects = realmManager.objects(CurrencyPairR.self,
//                                               sorted: [NSSortDescriptor(key: "date", ascending: false)])
//                .map { CurrencyPair(currencyPairR: $0) }
//
//            DispatchQueue.main.async {
//                self.currencies = objects
//            }
//        }
//    }
}

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @State var token: String = Settings.shared.apiToken

    var body: some View {
        NavigationView {
            List {
                tokenApi
            }
//            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var tokenApi: some View {
        VStack(alignment: .leading) {
            Text("API Token")
                .font(.callout)
                .bold()
            Spacer()
            TextField("Enter token", text: $token, onCommit: {
                print("onCommit", token)
            })
        }
    }
}
