//
//  ContentView.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import InvestModels
import SwiftUI

class MainViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var loadDB: LoadingState<Void> = .loading
    var dbManager: DBManager
    var latest: CurrencyPairServiceLatest { .shared }

    override init(env: Environment = .current) {
        dbManager = DBManager(env: env, realmManager: RealmManager())

        super.init(env: env)
    }

    func loadData() {
        guard loadDB == .loading else { return }

        Publishers.CombineLatest(dbManager.updateIfNeeded(), latest.$latest.dropFirst())
            .eraseToAnyPublisher().mapToVoid()
            .map { .loaded(object: $0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.loadDB, on: self)
            .store(in: &cancellables)
    }
}

extension MainView {
    static let settingsNavigationLink: some View = {
        Button(action: {}) {
            NavigationLink(destination: ViewFactory.settingsTabView) {
                Image(systemName: "gearshape")
            }
        }
    }()
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    @State var selection = 0

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
            Text("Loading...")
        }
    }

    var tabBarView: some View {
        TabView(selection: $selection) {
            profileView
            analyticsView
            targetsView
        }
        .accentColor(Color.appBlack)
    }

    var targetsView: some View {
        ViewFactory.targetsView.tabItem {
            VStack {
                Image(systemName: "target")
                Text("Target")
            }.font(.system(size: 16, weight: selection == 0 ? .bold : .regular))
        }.tag(1)
    }

    var profileView: some View {
        ViewFactory.homeView.tabItem {
            VStack {
                Image(systemName: selection == 0 ? "dollarsign.circle.fill" : "dollarsign.circle")
                Text("Profile")
            }.font(.system(size: 16, weight: selection == 0 ? .bold : .regular))
        }.tag(0)
    }

    var analyticsView: some View {
        ViewFactory.analyticsView.tabItem {
            VStack {
                Image(systemName: selection == 1 ? "chart.bar.fill" : "chart.bar")
                Text("Analytics")
                    .font(.system(size: 16, weight: selection == 1 ? .bold : .regular))
            }
        }.tag(2)
    }

//    var operationsView: some View {
//        ViewFactory.operationsView.tabItem {
//            VStack {
//                Image(systemName: "list.bullet.rectangle")
//                    .resizable()
//                Text("Operations")
//            }.font(.system(size: 16, weight: selection == 2 ? .bold : .regular))
//        }.tag(2)
//    }
}

// line.diagonal.arrow 􀫱
// slider.vertical.3 􀟲
//
