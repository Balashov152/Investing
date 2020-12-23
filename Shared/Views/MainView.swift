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
    @Published var loadingState: LoadingState<[Instrument]> = .loading
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Group {
            switch viewModel.loadingState {
            case .loading:
                Text("loading")
            case .loaded:
                tabBarView
            case let .failure(error):
                Text("error \(error.errorDescription.orEmpty)")
            }
        }
        .accentColor(Color(UIColor.systemOrange))
        // .onAppear(perform: viewModel.loadData)
    }

    var tabBarView: some View {
        TabView {
            profileView
            analyticsView
            operationsView
        }
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
