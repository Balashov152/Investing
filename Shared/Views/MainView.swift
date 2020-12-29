//
//  ContentView.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import CombineMoya
import InvestModels
import Moya
import SwiftUI

enum LoadingState<Object>: Equatable {
    static func == (lhs: LoadingState<Object>, rhs: LoadingState<Object>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.loaded(obj1), .loaded(obj2)):
            return true
        case let (.failure(err1), .failure(err2)):
            return true
        default: return false
        }
    }

    case loading

    case loaded(object: Object)
    case failure(error: LoadingError)

    var object: Object? {
        guard case let .loaded(object) = self else {
            return nil
        }
        return object
    }

    var error: LoadingError? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}

enum LoadingError: Error, LocalizedError {
    case error(code: Int)

    var errorDescription: String? {
        switch self {
        case let .error(code):
            return "Status code" + code.string
        }
    }
}

class MainViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var loadDB: LoadingState<Void> = .loading

    var dbManager: DBManager

    override init(env: Environment = .current) {
        dbManager = DBManager(env: env, realmManager: RealmManager())

        super.init(env: env)
    }

    func loadData() {
        guard loadDB == .loading else { return }

        dbManager.updateIfNeeded { [unowned self] in
            self.loadDB = .loaded(object: ())
        }
    }

    func loadCurrency() {
        dbManager.updateCurrency()
            .sink(receiveValue: {}).store(in: &cancellables)
    }
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Group {
            switch viewModel.loadDB {
            case .loading:
                loadingView
            case .loaded:
                tabBarView
            case let .failure(error):
                Text("error \(error.errorDescription.orEmpty)")
            }
        }
        .onAppear(perform: viewModel.loadData)
    }

    var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Text("Loading..")
        }
    }

    var tabBarView: some View {
        TabView {
            profileView
            analyticsView
            operationsView
            SettingsTabView(viewModel: .init())
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
        }
        .accentColor(Color(UIColor.systemOrange))
    }

    var profileView: some View {
        ViewFactory.homeView()
            .tabItem {
                VStack {
                    Image(systemName: "dollarsign.circle")
                    Text("Profile")
                }
            }
    }

    var analyticsView: some View {
        ViewFactory.analyticsView()
            .tabItem {
                VStack {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Analytics")
                }
            }
    }

    var operationsView: some View {
        ViewFactory.operationsView()
            .tabItem {
                VStack {
                    Image(systemName: "list.bullet")
                    Text("Operations")
                }
            }
    }
}

// line.diagonal.arrow 􀫱
// slider.vertical.3 􀟲
//
