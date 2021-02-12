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
}

struct RootView: View {
    @EnvironmentObject var session: UserSession

    var body: some View {
        if session.isAuthorized {
            ViewFactory.mainView
        } else {
            AuthorizationView(viewModel: .init(session: session))
        }
    }
}
