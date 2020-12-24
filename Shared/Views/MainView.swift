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

enum LoadingState<Object> {
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
    @Published var loadDB: LoadingState<Void> = Storage.isFillDB ? .loaded(object: ()) : .loading

    var dbManager: DBManager

    override init(env: Environment = .current) {
        dbManager = DBManager(env: env, realmManager: RealmManager())

        super.init(env: env)
    }

    func loadData() {
        loadDB = .loading
        dbManager.updateIfNeeded { [unowned self] in
            self.loadDB = .loaded(object: ())
        }
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
