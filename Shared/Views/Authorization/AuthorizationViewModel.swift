//
//  AuthorizationViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 23.04.2021.
//

import Combine

class AuthorizationViewModel: EnvironmentCancebleObject, ObservableObject {
    let session: UserSession

    @Published var isSandbox: Bool {
        willSet {
            env.settings.isSandbox = newValue
        }
    }

    @Published var error: String?
    @Published var apiToken: String = "" {
        willSet {
            error = nil
        }
    }

    lazy var actionButton: () -> Void = { [unowned self] in
        Storage.token = self.apiToken

        self.env.api().accountService.getAccounts()
            .sink { error in
                switch error {
                case let .failure(error):
                    Storage.token = ""
                    self.error = "Token is invalid".localized
                case .finished:
                    break
                }
            } receiveValue: { _ in
                self.session.isAuthorized = true
            }.store(in: &self.cancellables)
    }

    init(session: UserSession, env: Environment = .current) {
        self.session = session
        isSandbox = env.settings.isSandbox

        super.init(env: env)
    }
}
