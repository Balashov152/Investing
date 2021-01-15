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

class MainViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var loadDB: LoadingState<Void> = .loading
    var dbManager: DBManager

    override init(env: Environment = .current) {
        dbManager = DBManager(env: env, realmManager: RealmManager())

        super.init(env: env)
    }

    func loadData() {
        guard loadDB == .loading else { return }
        dbManager.updateCurrency()
            .sink(receiveValue: {}).store(in: &cancellables)

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
                        Image(systemName: "gearshape")
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
                    Image(systemName: "list.bullet.rectangle")
                    Text("Operations")
                }
            }
    }
}

// line.diagonal.arrow 􀫱
// slider.vertical.3 􀟲
//
