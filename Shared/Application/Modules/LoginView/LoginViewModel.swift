//
//  LoginViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Combine

protocol LoginViewOutput: AnyObject {
    func didSuccessLogin()
}

class LoginViewModel: CancebleObject, ObservableObject {
    @Published var contentState: ContentState = .content

    private let portfolioManager: PortfolioManaging
    private weak var output: LoginViewOutput?

    private var userAccountsCancellable: AnyCancellable?

    init(
        portfolioManager: PortfolioManaging,
        output: LoginViewOutput
    ) {
        self.portfolioManager = portfolioManager
        self.output = output
    }

    func tryToLoadAccounts(token: String) {
        Storage.token = token

        userAccountsCancellable = portfolioManager
            .userAccounts()
            .sink { [unowned self] completion in
                if let error = completion.error {
                    self.contentState = .failure(
                        error: .simpleError(string: error.localizedDescription)
                    )
                    Storage.token = ""
                }
            } receiveValue: { [unowned self] _ in
                self.output?.didSuccessLogin()
            }
    }
}
