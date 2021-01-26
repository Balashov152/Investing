//
//  RootView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import SwiftUI

class RootViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var isAuthorized = Storage.isAuthorized

    @Published var apiToken: String = ""
    lazy var checkToken: () -> Void = { [unowned self] in
        self.isAuthorized = true // TODO: Add check token
    }

    override init(env: Environment = .current) {
        super.init(env: env)
        #if DEBUG
            apiToken = "t.ElO9J6o7HNsTSVH5LG6tRrMqG3bAKQFG3YehULcdPaYzhK0CXcyMVy4rhtbNUuOHwXo8VAs-QUgA-KbHNLg5yg"
        #endif
    }

    override func bindings() {
        super.bindings()
        $apiToken.sink { token in
            Storage.token = token
        }.store(in: &cancellables)
    }
}

struct RootView: View {
    @ObservedObject var viewModel: RootViewModel

    var body: some View {
        if viewModel.isAuthorized {
            ViewFactory.mainView
        } else {
            AuthorizationView(apiToken: $viewModel.apiToken, doneButton: {
                viewModel.checkToken()
            })
        }
    }
}
