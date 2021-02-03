//
//  RootView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Combine
import Moya
import SwiftUI

class UserSession: EnvironmentCancebleObject, ObservableObject {
    @Published var isAuthorized = Storage.isAuthorized

    func checkToken(token: String) -> MoyaError? {
        Storage.token = token
        env.api().accountService.getAccounts()
            .replaceError(with: [])
            .sink { accounts in
                if accounts.isEmpty {
                    Storage.token = ""
                } else {
                    self.isAuthorized = true
                }
            }.store(in: &cancellables)

        return nil
    }
}

struct RootView: View {
    @EnvironmentObject var session: UserSession

    var body: some View {
        if session.isAuthorized {
            ViewFactory.mainView
        } else {
            AuthorizationView(viewModel: .init(checkToken: session.checkToken))
        }
    }
}
