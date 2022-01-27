//
//  SwitchVersionView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 18.01.2022.
//

import Foundation
import SwiftUI

class SwitchVersionViewModel: CancebleObject, ObservableObject {
    @Published var currentVersion: CurrentVersion? = .none

    let moduleFactory: ModuleFactoring

    init(moduleFactory: ModuleFactoring) {
        self.moduleFactory = moduleFactory
    }
}

extension SwitchVersionViewModel {
    enum CurrentVersion {
        case old
        case new
    }
}

struct SwitchVersionView: View {
    @ObservedObject var viewModel: SwitchVersionViewModel

    init(viewModel: SwitchVersionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.currentVersion {
        case .none:
            VStack(spacing: Constants.Paddings.m) {
                Button(action: {
                    viewModel.currentVersion = .old
                }, label: {
                    Text("Old Version View")
                })

                Button(action: {
                    viewModel.currentVersion = .new
                }, label: {
                    Text("New Version View")
                })
            }

        case .new:
            viewModel.moduleFactory.tabBarModule()

        case .old:
            viewModel.moduleFactory.oldVersionView()
        }
    }
}
